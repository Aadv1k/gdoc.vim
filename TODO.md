### Basic setup 
- [x] Setup python to work with vim 
- [x] Wrap the API with a workable wrapper
- [x] Setup a basic write action as an initial starting point (will be put in the `main` branch)
- [x] Setup a post install script to install dependencies
- [x] An initial simple function to communicate with the API

### Initial `:Gdoc` command - 3/10/2022
- [ ] `:Gdoc write {filename}`
    - Writes the document to google docs with the filename
    - Creates or appends to a local "db" file to contain all the doc ids
- [ ] `:Gdoc open <TAB>{name: ids}`
    - Lists the names ids from the local "db" files
    - Creates a new buffer with the contents of file in it  
