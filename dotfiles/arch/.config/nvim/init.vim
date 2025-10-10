call plug#begin()

" Theme
Plug 'sainnhe/gruvbox-material'

" Bar
Plug 'nvim-lualine/lualine.nvim'
"Plug 'vim-airline/vim-airline'

" Settings
Plug 'ap/vim-css-color'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-tree/nvim-web-devicons'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

source $HOME/.config/nvim/theme.vim

" filetype plugin indent on " allow auto-indenting depending on file type
filetype plugin on
" syntax on                 " syntax highlighting

" set nocompatible          " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set number                  " add line numbers
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
set ttyfast                 " Speed up scrolling in Vim

" transparency
highlight Normal ctermbg=none guibg=none
highlight NonText ctermbg=none guibg=none

" whitespace cleanup
autocmd BufWritePre * :%s/\s\+$//e

" visual feedback for yanks
au TextYankPost * silent! lua vim.highlight.on_yank()

" plugin: autopairs
lua << END
	require("nvim-autopairs").setup {}
END

" autoformat
"autocmd BufWritePre *.js,*.ts,*.py,*.lua :call CocAction('format')
