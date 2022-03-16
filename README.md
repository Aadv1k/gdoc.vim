# Gdoc.vim

Google docs integration for vim/neovim.

## Features

This is a WIP and a bare bones implementation currently you can :-

- Create google documents from vim
- Sync the documents with changes
- See [TODO.md](./TODO.md) for more future plans for the project; feel free to raise any issue for a feature or bug.

## Installation

**Make sure you have the following**

- python >= 3.6 (including pip)
- vim 8+ with +python or +python3
- **for neovim users** pynvim `pip install pynvim`

### vim-plug

```vim
Plug 'aadv1k/gdoc.vim', {'do': './install.py'}
```

### Initializing the app

For this to work, you need to have a google account, then you need to create a new google cloud project.
[Creating a google cloud project](https://developers.google.com/workspace/guides/create-project)

Then to use the app, you have to activate `drive api` (to create documents) and `google docs` (to edit/write documents) api from
[Google api dashboard](https://console.cloud.google.com/apis/dashboard)

After this, you need to download credentials, do the steps necessary to setup a consent screen and an
oAuth login, then download the credentials and place them anywhere you like. Then put the path of
the credentials in the `g:path_to_creds`.

In the example below, `credentials.json` is placed in `~/.vim` you can use any valid credential file, and put it's path here.

```vim
let g:path_to_creds = '/home/aadv1k/.vim/credentials.json'
let g:gdoc_file = '/home/aadv1k/.vim/.gdoc' " optional; default is ./.gdoc
let g:token_directory = '/home/aadv1k/.vim/' " optional; default is ./
```

The `g:token_directory` is where token for your api should live, if you don't want the oAuth screen
to pop-up everytime, you should set a standard directory to place the token.

`g:gdoc_file` is quite important as it is used to map the files to the
documents in the cloud, read the [USAGE](#Usage) for more info about `.gdoc` 

## Usage

This plugin creats a local file called `.gdoc` this file is used to sync and
keep track of the documents in that particular folder. Deleting or editing
`.gdoc` file might lead to unexpected behaviour, so it is advised not to.

### `:Gdoc write`

This essentially creates a new google document with the current file name, and
appends some extra info to `.gdoc` in the local directory which will later be
used by other functions. It does so using the following scheme `{file_name.[extension]} -> {document_id}`

### `:Gdoc sync` (kinda)

This accesses the document associated with that particular filename using
`.gdoc`, it then formats a request that first clears the entire document, and
writes your current file contents.

### `:Gdoc rm`

Delete the document associated with the file from google drive.

## Screenshots

<img src="./screenshots/1.1.png" alt="1.png" width="500px">
