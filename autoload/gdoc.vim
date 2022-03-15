function gdoc#LoadCommand(plug_path, path_to_creds, token_directory, mode)
    call gdoc#Gdoc(a:plug_path, a:path_to_creds, a:token_directory)
    if a:mode  == 'write'
        call gdoc#WriteDoc()
    elseif a:mode  == 'sync'
        call gdoc#SyncDoc()
    elseif a:mode  == 'rm'
        call gdoc#RmDoc()
    else
        echom "Exaustive handling of Arguments; " . a:mode . " Not found"
    endif
endfunction

function gdoc#Gdoc(plug_path, path_to_creds, token_directory)
python3 << EOF
import vim
import sys
import os

plugin_root_dir = vim.eval('a:plug_path')
python_root_dir = os.path.normpath(os.path.join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

from gdoc import doc_query

creds_path = vim.eval('a:path_to_creds')
token_path = vim.eval('a:token_directory')

query = doc_query(creds_path, token_path)

EOF
endfunction

function gdoc#RmDoc()
python3 << EOF 

target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")

local_doc = query.open_doc_from_file(target_file_name)

if local_doc != -1:
    file_id = local_doc[1]
    file_name = local_doc[2]
    line = local_doc[3]

    dq = query.delete_doc(file_id)
    if dq[0] == 0:
        query.delete_line_from_file(line)
        print('[INFO] Successfully deleted %s' % file_name)
    else:
        print('[ERROR] Something went wrong -- %s' % dq[1])
else:
    print('[INFO] Document "%s" is not synced with google docs yet, try running :Gdoc write ' % target_file_name)

EOF 
endfunction


function gdoc#SyncDoc()
python3 << EOF 

target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")

if os.path.exists('./.gdoc') and query.open_doc_from_file(fname = target_file_name, idx = '') != -1:
    id = query.open_doc_from_file(fname = target_file_name, idx = '')[1]

    print('[INFO] Syncing document...')

    with open(target_file_path) as file:
        new_content = file.read()

    if query.sync_doc(new_content, id) != -1:
        print('[INFO] Successfully synced the document.')

    else:
        print('[ERROR] Something went wrong')

else:
    print('[INFO] Document "%s" is not synced with google docs yet, try running :Gdoc write ' % target_file_name)
EOF 

endfunction

function gdoc#WriteDoc()
python3 << EOF
import os
import vim
import sys

def main():
    target_file = vim.eval("expand('%:p')")
    target_file_name = vim.eval("expand('%:t')")

    if not target_file:
        return -1

    with open(target_file, 'r') as file:
        file_contents = file.read()

    create_blob = { 'title': target_file_name }
    edit_blob = [{ 'insertText': { 'location': { 'index': 1, }, 'text': file_contents } }]

    doc = query.create_doc(create_blob)

    if doc['id'] != None:
        print(f"[SUCCESS] Created a document with the id {doc['id']} and title '{doc['title']}'")

        query.write_id_to_file(doc['id'], doc['title'])
        print(f"[SUCCESS] Saved the document ID to .gdoc ")
        
        if query.edit_doc(doc['id'], edit_blob):
            print(f"[SUCCESS] Successfully written the document with the id {doc['id']} ")
    else:
        return -2


target_file_name = vim.eval("expand('%:t')")
if os.path.exists('./.gdoc') and query.open_doc_from_file(fname = target_file_name, idx = '') != -1:
        print('[INFO] Document "%s" already exists in google docs.' % target_file_name)
else:
    i = main()

    if i == -1:
        print('[ERROR] Empty buffer, no text to write.')
    elif i == -2:
        print('[ERROR] Something went wrong.')
EOF
endfunction
