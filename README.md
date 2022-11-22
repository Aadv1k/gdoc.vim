# Gdoc.vim

Google docs integration for vim/neovim.

## Features

- Sync a local file to google docs
- Delete the google doc from google drive
- Download the contents of the document to your local file
- Upload the contents of your local file to it's google doc

## Installation

**Make sure you have the following**

- python >= 3.6 (including pip)
- vim 8+ with python3+
- _for neovim users_ pynvim (`pip install pynvim`)

### vim-plug

```vim
Plug 'aadv1k/gdoc.vim', {'do': './install.py'}
" For the dev branch
Plug 'aadv1k/gdoc.vim', {'do': './install.py', 'branch': 'dev'}
```

### packer.nvim

```lua
use {'aadv1k/gdoc.vim', run = './install.py'}
-- For the dev branch
use {'aadv1k/gdoc.vim', run = './install.py', branch = 'dev'}
```

## Initializing the app

For this to work, you need to have a google account, then you need to create a new google cloud project.
[Creating a google cloud project](https://developers.google.com/workspace/guides/create-project)

Then to use the app, you have to activate `drive api` (to create documents) and `google docs` (to edit/write documents) api from
[Google api dashboard](https://console.cloud.google.com/apis/dashboard)

After this, you need to download credentials, do the steps necessary to setup a consent screen and an
oAuth login, then download the credentials and place them anywhere you like. Then put the path of
the credentials in the `g:path_to_creds`.

In the example below, `credentials.json` is placed in `~/.vim` you can use any valid credential file, and put it's path here.

```vim
let g:path_to_creds = '~/.vim/credentials.json' " this is required
let g:gdoc_file_path = '~/.vim/' " optional; default is ./
let g:token_directory = '~/.vim/' " optional; default is ./
```

These paths will be valid both on windows and unix as they are passed through [`os.path.expanduser()`](https://docs.python.org/3/library/os.path.html#os.path.expanduser) in python.

- `g:token_directory` is where token for your api should live, if you don't
  want the oAuth screen to pop-up everytime, you should set a standard directory
  to place the token.

- `g:gdoc_file_path` is the directory where the `.gdoc` file is placed, this file
  is used to map local files to their corresponding document in the drive

## Usage

> This plugin creates a file called `.gdoc` which is placed in a folder you can specify via `g:gdoc_file_path` by default it is made in every directory you execute `:Gdoc write`.
> `.gdoc` is used to keep track of the local files and their documents(ids). It does so using the following format `{full_file_path} -> {file_id}\n`

| Command          | Function          | Description                                                                  |
| ---------------- | ----------------- | ---------------------------------------------------------------------------- |
| `:Gdoc write`    | `gdoc#WriteDoc()` | Write your current file to a google doc with the same name                   |
| `:Gdoc sync`     | `gdoc#Sync()`     | Upload the changes in your local file to google doc                          |
| `:Gdoc sync-doc` | `gdoc#SyncDoc()`  | Download the changes in google doc to local file                             |
| `:Gdoc rm`       | `gdoc#RmDoc()`    | Delete the google document associated with the local file from google drive. |
