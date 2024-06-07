call plug#begin()

Plug 'ap/vim-css-color'

" Themes
Plug 'sainnhe/edge'
Plug 'vim-airline/vim-airline'

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

" Important!!
if has('termguicolors')
  set termguicolors
endif

" The configuration options should be placed before `colorscheme edge`.
let g:edge_style = 'aura'
let g:edge_better_performance = 1

colorscheme edge
let g:airline_theme = 'edge'
