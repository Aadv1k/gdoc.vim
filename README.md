# Gdoc.vim
Google docs integration for vim/neovim.

## Features
This is a WIP and a bare bones implementation currently you can :-

- Create google documents from vim
- Sync the documents with changes 
- See [TODO.md](./TODO.md) for more details.

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

Then To initialize the app, you have to activate `drive api` and `google docs` api from
[Google api dashboard](https://console.cloud.google.com/apis/dashboard)

After this, you need to download credentials, do the steps necessary to setup a consent screen and an
oAuth login, then download the credentials and place them anywhere you like. Then put the path of
the credentials in the `g:path_to_creds`. In the example below, `credentials.json` is placed in `~/.vim`

```vim
let g:path_to_creds = '/home/aadv1k/.vim/credentials.json'
let g:token_directory = '/home/aadv1k/.vim/'
```

The `g:token_directory` is where token for your api should live, if you don't want the oAuth screen
to pop-up everytime, you should set a standard directory to place the token.

## Usage

`:Gdoc write`
This essentially creates a new google document with the current file name, and
appends some extra info to `.gdoc` in the local directory which will later be
used by other functions.

`:Gdoc sync`
This takes your file contents, and based on the id in `.gdoc` it updates the
google document with the local file content. if it doesn't find the id, it will
ask you to run `:Gdoc write` to sync it.

## Screenshots

<img src="./screenshots/1.1.png" alt="1.png" width="500px">
