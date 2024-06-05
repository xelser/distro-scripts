call plug#begin()

Plug 'ap/vim-css-color'

" Themes
Plug 'navarasu/onedark.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'

" Settings
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'

call plug#end()

"filetype plugin indent on   "allow auto-indenting depending on file type
filetype plugin on
"syntax on                   " syntax highlighting

"set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set number                  " add line numbers
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set ttyfast                 " Speed up scrolling in Vim

colorscheme onedark

lua << END
require('lualine').setup { options = { theme = 'onedark' }}
END
