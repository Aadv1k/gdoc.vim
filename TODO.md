### Basic setup

- [x] Setup python to work with vim
- [x] Wrap the API with a workable wrapper
- [x] Setup a basic write action as an initial starting point (will be put in the `main` branch)
- [x] Setup a post install script to install dependencies
- [x] An initial simple function to communicate with the API

### Initial `:Gdoc` command - 3/10/2022

- [x] `:Gdoc write`
  - Writes the document to google docs with your current file name (with extension)
  - Creates or appends to a local "db" file to contain all the doc ids
- [x] `:Gdoc sync`
  - Update the document with your local changes

- [x] `:Gdoc rm`

  - Remove the document associated with your current file
  - Delete it from `.gdoc`

- [ ] Maybe change the implementation of `.gdoc` to be in a standard directory instead of it being in every folder
