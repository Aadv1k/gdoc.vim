if !has('python3')
    echo "Error: Python3 is required for this to work. for more info, checkout https://github.com/aadv1k"
    finish
endif



let path_to_creds = get(g:, 'path_to_creds', "-1")
let token_directory = get(g:, 'token_directory', "-1")

if path_to_creds == -1
    echo "Please provde a credential file path."
    finish
endif


if token_directory == -1
    let token_directory = './'
endif


let g:buf_content = join(getline(1,'$'), "\n")
let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

python3 << EOF

import vim
import os
import sys


plugin_root_dir = vim.eval('s:plugin_root_dir')
python_root_dir = os.path.normpath(os.path.join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

import gdoc
t = gdoc.make_query(vim.eval('path_to_creds'), vim.eval('token_directory'))
EOF


function WriteDoc(name)

python3 << EOF

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

command! -nargs=1 -complete=command Gdoc call WriteDoc(<q-args>)
