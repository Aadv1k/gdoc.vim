function gdoc#LoadCommand(plug_path, path_to_creds, token_directory, gdoc_path, opts)
    call gdoc#Gdoc(a:plug_path, a:path_to_creds, a:token_directory, a:gdoc_path)
    let args = split(a:opts, ' ')
    let mode = args[0]

    if mode  == 'write'
        call gdoc#WriteDoc()
    elseif mode  == 'upload'
        call gdoc#UploadDoc()
    elseif mode  == 'download'
        call gdoc#DownloadDoc()
    elseif mode  == 'rm'
        call gdoc#RmDoc()
    else
        echoerr "Exaustive handling of Arguments; " . mode . " Not found"
    endif
endfunction


function gdoc#Gdoc(plug_path, path_to_creds, token_directory, gdoc_path)
""""""""""""""""""""
python3 << EOF
import vim
import sys
from os.path import normpath, join, expanduser

plugin_root_dir = vim.eval('a:plug_path')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

from gdoc import doc_query
from fmt_msg import GdocErr

creds_path = expanduser(vim.eval('a:path_to_creds'))
token_path = expanduser(vim.eval('a:token_directory'))
gdoc_path = expanduser(join(vim.eval('a:gdoc_path'), '.gdoc'))

query = doc_query(creds_path, token_path, gdoc_path)
EOF
""""""""""""""""""""
endfunction

function gdoc#RmDoc()
python3 << EOF 
target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")
local_doc = query.open_doc_from_file(target_file_path)

if local_doc != -1:
    file_id = local_doc[1]
    file_name = local_doc[2]
    line = local_doc[3]

    dq = query.delete_doc(file_id)
    if dq[0] == 0:
        query.delete_line_from_file(line)
        print('[gdoc.vim] Successfully deleted \"%s\" from google docs' % target_file_name)
    else:
        raise GdocErr('Something went wrong')
else:
    raise GdocErr("Document \"%s\" is not synced with google docs yet, try running :Gdoc write" % target_file_name)
EOF 
endfunction

function gdoc#DownloadDoc()
python3 << EOF 


target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")
document = query.open_doc_from_file(target_file_path)

if document != -1:
    remote_doc_content = document[0][0]
    remote_file = document[1]
    local_file = document[2]

    with open(local_file, 'w') as file:
    	file.write(remote_doc_content)

    print('[gdoc.vim] Downloaded remote doc')
else:
    raise GdocErr("Document \"%s\" is not synced with google docs yet, try running :Gdoc write" % target_file_name)
EOF 
:edit!
endfunction 

function gdoc#UploadDoc()
python3 << EOF 

import os

target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")


if os.path.exists(query.gdoc_file) and query.open_doc_from_file(fname = target_file_path, idx = '') != -1:
    print("[gdoc.vim] Syncing document...")
    id = query.open_doc_from_file(fname = target_file_path, idx = '')[1]

    with open(target_file_path) as file:
        new_content = file.read()

    if query.sync_doc(new_content, id) != -1:
        print("[gdoc.vim] Successfully uploaded to the remote doc")

    else:
        raise GdocErr("Something went wrong")
else:
    raise GdocErr("Document \"%s\" is not synced with google docs yet, try running :Gdoc write'" % target_file_name)
EOF 

endfunction

function gdoc#WriteDoc()
python3 << EOF
import os
import vim
import sys

def main():
    target_file_path = vim.eval("expand('%:p')")
    target_file_name = vim.eval("expand('%:t')")

    if not target_file_path:
        return -1

    with open(target_file_path, 'r') as file:
        file_contents = file.read()

    create_blob = { 'title': target_file_name }
    edit_blob = [{ 'insertText': { 'location': { 'index': 1, }, 'text': file_contents } }]

    doc = query.create_doc(create_blob)

    if doc['id'] != None:
        print("[gdoc.vim] Created a document with the id \"%s\" and title \"%s\" " % (doc['id'], doc['title']))


        query.write_id_to_file(doc['id'], target_file_path)
        print("[gdoc.vim] Saved the document ID to %s" % query.gdoc_file)
        
        if query.edit_doc(doc['id'], edit_blob):
            print("[gdoc.vim] Successfully written the document with the id %s"  % doc['id'])
    else:
        return -2


target_file_path = vim.eval("expand('%:p')")
target_file_name = vim.eval("expand('%:t')")

if os.path.exists(query.gdoc_file) and query.open_doc_from_file(fname = target_file_path, idx = '') != -1:
        print("[gdoc.vim] Document \"%s\" already exists in google docs." % target_file_name)
else:
    i = main()
    if i == -1:
        raise GdocErr('[gdoc.vim] Empty buffer, no text to write.')
    elif i == -2:
        raise GdocErr('[gdoc.vim] Something went wrong.')
EOF
endfunction
