function doc#Gdoc(plug_path, path_to_creds, token_directory)

python3 << EOF
import vim
import sys
import os

plugin_root_dir = vim.eval('a:plug_path')
python_root_dir = os.path.normpath(os.path.join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

import gdoc
t = gdoc.make_query(vim.eval('a:path_to_creds'), vim.eval('a:token_directory'))
EOF

endfunction

function doc#WriteDoc(plug_path, name)
python3 << EOF
import os
import vim
import sys

plugin_root_dir = vim.eval('a:plug_path')
python_root_dir = os.path.normpath(os.path.join(plugin_root_dir, '..' ,'python'))
sys.path.insert(0, python_root_dir)

import gdoc

def main():
    create_blob = { 'title': vim.eval('a:name') }

    if len(vim.eval('join(getline(1,"$"), "\n")')) == 0:
        return -1

    edit_blob = [ { 'insertText': { 'location': { 'index': 1, }, 'text': vim.eval('join(getline(1,"$"), "\n")') } }, ]

    doc = t.create_doc(create_blob)
    if doc['id'] != None:
        print(f"[SUCCESS] Created a document with the id {doc['id']} and title '{doc['title']}'")

        if t.edit_doc(doc['id'], edit_blob):
            print(f"[SUCCESS] Successfully written the document with the id {doc['id']} ")
    else:
        return -2

i = main()

if i == -1:
    print('[ERROR] Empty buffer, no text to write.')
elif i == -2:
    print('[ERROR] Something went wrong.')
EOF

endfunction


function doc#InitAndWrite(plug_path, path_to_creds, token_directory, name)
    call doc#Gdoc(a:plug_path, a:path_to_creds, a:token_directory)
    call doc#WriteDoc(a:plug_path, a:name)
endfunction
