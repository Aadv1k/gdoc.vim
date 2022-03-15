if !has('python3')
    echom "[ERROR] Python3 is required for this to work"
    finish
endif

let path_to_creds = get(g:, 'path_to_creds', "-1")
let token_directory = get(g:, 'token_directory', "./")
let plug_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

if path_to_creds == -1
    echom "[ERROR] Please provde a credential file path"
    finish
endif

function! GdocComplete(ArgLead, CmdLine, CursorPos)
    return ['sync', 'write', 'rm']
endfunction

command! -nargs=* -complete=customlist,GdocComplete Gdoc call gdoc#LoadCommand(plug_path, path_to_creds, token_directory, <f-args>)
