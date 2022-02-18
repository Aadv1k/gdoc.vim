
function doc#InstallDeps()

python3 << EOF
from os import path
import vim
import subprocess

req='./requirements.txt'

if path.exists(path.normpath(path.join(os.getcwd(), '..', req))):
    vim.command("let g:build_status = 1")
    subprocess.call(['python3', '-m', 'pip', 'install', '-r', path.normpath(path.join(os.getcwd(), '..', req))])
else:
    vim.command("let g:build_status = -1")
EOF

endfunction


function doc#Gdoc(path_to_creds, token_directory)
let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

python3 << EOF
import vim
import os
import sys
import gdoc


plugin_root_dir = vim.eval('s:plugin_root_dir')
python_root_dir = os.path.normpath(os.path.join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

t = gdoc.make_query(vim.eval('a:path_to_creds'), vim.eval('a:token_directory'))
EOF

endfunction


function doc#WriteDoc(name)
python3 << EOF

from os import path
import vim
import subprocess

def main():
    create_blob = { 'title': vim.eval('a:name') }

    if len(vim.eval('join(getline(1,"$"), "\n")')) == 0:
        return -1

    edit_blob = [ 
        { 
            'insertText': { 'location': { 'index': 1, }, 'text': vim.eval('join(getline(1,"$"), "\n")') } 
        }, 
    ]

    doc = t.create_doc(create_blob)
    if doc['id'] != None:
        print(f"Created a document with the id {doc['id']} and title '{doc['title']}'")

        if t.edit_doc(doc['id'], edit_blob):
            print(f"Successfully written the document with the id {doc['id']}")
    else:
        return -2

i = main()

if i == -1:
    print('Empty buffer, no text to write.')
elif i == -2:
    print('Something went wrong.')
EOF

endfunction
