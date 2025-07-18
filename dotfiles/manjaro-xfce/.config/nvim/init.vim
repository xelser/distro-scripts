call plug#begin()

Plug 'ap/vim-css-color'

" Themes
Plug 'sainnhe/gruvbox-material'
Plug 'nvim-lualine/lualine.nvim'
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
"set incsearch               " incremental search
set number                  " add line numbers
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set ttyfast                 " Speed up scrolling in Vim

" Important!!
if has('termguicolors')
	set termguicolors
endif

" For dark version.
set background=dark
" For light version.
"set background=light

" Set contrast.
" This configuration option should be placed before `colorscheme gruvbox-material`.
" Available values: 'hard', 'medium'(default), 'soft'
let g:gruvbox_material_background = 'hard'

" For better performance
let g:gruvbox_material_better_performance = 1

" airline theme
let g:airline_theme = 'gruvbox_material'

colorscheme gruvbox-material
