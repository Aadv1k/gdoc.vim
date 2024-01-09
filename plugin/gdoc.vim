

let g:path_to_creds = '~/.vim/credentials.json' " this is required
let g:gdoc_file_path = '~/.vim/' " optional; default is ./
let g:token_directory = '~/.vim/' " optional; default is ./

if !has('python3')
    echoerr "[gdoc.vim] Python3 is required for gdoc.vim to work."
    finish
endif

let path_to_creds = get(g:, 'path_to_creds', "-1")
let token_directory = get(g:, 'token_directory', "./")
let plug_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let gdoc_path = get(g:, 'gdoc_file_path', "./")


if path_to_creds == -1
    echoerr "[gdoc.vim] Please provde the credentials file."
    finish
endif

function! GdocComplete(ArgLead, CmdLine, CursorPos)
    return ['sync', 'sync-doc', 'write', 'rm', 'fetch-doc']
endfunction

command! -nargs=+ -complete=customlist,GdocComplete Gdoc call gdoc#LoadCommand(plug_path, path_to_creds, token_directory, gdoc_path, <q-args>)
