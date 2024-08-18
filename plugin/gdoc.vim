if !has('python3')
    echoerr "[gdoc.vim] Python3 is required for gdoc.vim to work."
    finish
endif

" User can specify paths to credentials file, gdoc and token directory using the expressions:
"   let g:path_to_creds = '/some-path/some-credentials-file.json'
"   let g:gdoc_file_path = '/some-directory'
"   let g:token_directory = '/some-directory'

" If no user specified path exists, we will default to:
"   ~/.vim/credentials.json for credentials
" . ~/.vim/ for doc
" . ~/.vim/ for token directory

let path_to_creds = get(g:, 'path_to_creds', '~/.vim/credentials.json')
let token_directory = get(g:, 'token_directory', '~/.vim/')
let gdoc_path = get(g:, 'gdoc_file_path', '~/.vim/')
let plug_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! GdocComplete(ArgLead, CmdLine, CursorPos)
    return ['sync', 'sync-doc', 'write', 'rm', 'fetch-doc']
endfunction

command! -nargs=+ -complete=customlist,GdocComplete Gdoc call gdoc#LoadCommand(plug_path, path_to_creds, token_directory, gdoc_path, <q-args>)
