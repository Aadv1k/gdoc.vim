function gdoc#LoadCommand(plug_path, path_to_creds, token_directory, gdoc_path, opts)
    call gdoc#Gdoc(a:plug_path, a:path_to_creds, a:token_directory, a:gdoc_path)
    let args = split(a:opts, ' ')
    let mode = args[0]
    if mode  == 'write'
        call gdoc#WriteDoc()
    elseif mode  == 'sync'
        call gdoc#SyncDoc()
    elseif mode  == 'rm'
        call gdoc#RmDoc()
    else
        echom "Exaustive handling of Arguments; " . mode . " Not found"
    endif
endfunction


function gdoc#Gdoc(plug_path, path_to_creds, token_directory, gdoc_path)
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
gdoc_path = vim.eval('a:gdoc_path')

query = doc_query(creds_path, token_path, gdoc_path)

EOF
endfunction

function gdoc#Msg(msg, mode)
    if a:mode == 'warn'
        echohl WarningMsg
    elseif a:mode == 'error'
        echohl ErrorMsg
    endif

    echom a:msg

    echohl None
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
        vim.command("call gdoc#Msg('[gdoc.vim] Successfully deleted \"%s\" from google docs', 'warn')" % target_file_name)
    else:
        vim.command("call gdoc#Msg('[gdoc.vim] Something went wrong', 'error')")
else:
    vim.command("call gdoc#Msg('[gdoc.vim] Document \"%s\" is not synced with google docs yet, try running :Gdoc write', 'error')" % target_file_name)
EOF 
endfunction


function gdoc#SyncDoc()
python3 << EOF 

target_file_name = vim.eval("expand('%:t')")
target_file_path = vim.eval("expand('%:p')")


if os.path.exists(query.gdoc_file) and query.open_doc_from_file(fname = target_file_path, idx = '') != -1:
    vim.command("call gdoc#Msg('[gdoc.vim] Syncing document...', 'warn')")
    id = query.open_doc_from_file(fname = target_file_path, idx = '')[1]

    with open(target_file_path) as file:
        new_content = file.read()

    if query.sync_doc(new_content, id) != -1:
        vim.command("call gdoc#Msg('[gdoc.vim] Successfully synced the document.', 'warn')")

    else:
        vim.command("call gdoc#Msg('[gdoc.vim] Something went wrong', 'error')")

else:
    vim.command("call gdoc#Msg('[INFO] Document \"%s\" is not synced with google docs yet, try running :Gdoc write', 'error')" % target_file_name)
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
        vim.command("call gdoc#Msg('[gdoc.vim] Created a document with the id \"%s\" and title \"%s\" ', 'warn')" % (doc['id'], doc['title']))


        query.write_id_to_file(doc['id'], target_file_path)
        vim.command("call gdoc#Msg('[gdoc.vim] Saved the document ID to %s', 'warn')" % query.gdoc_file)
        
        if query.edit_doc(doc['id'], edit_blob):
            vim.command("call gdoc#Msg('[gdoc.vim] Successfully written the document with the id %s', 'warn')" % doc['id'])
    else:
        return -2


target_file_path = vim.eval("expand('%:p')")
target_file_name = vim.eval("expand('%:t')")

if os.path.exists(query.gdoc_file) and query.open_doc_from_file(fname = target_file_path, idx = '') != -1:
        vim.command("call gdoc#Msg('[gdoc.vim] Document \"%s\" already exists in google docs.', 'error')" % target_file_name)
else:
    i = main()
    if i == -1:
        vim.command("call gdoc#Msg('[gdoc.vim] Empty buffer, no text to write.', 'error')" % target_file_name)
    elif i == -2:
        vim.command("call gdoc#Msg('[gdoc.vim] Something went wrong.', 'error')" % target_file_name)
EOF
endfunction
