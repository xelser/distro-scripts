call plug#begin()

" Theme
Plug 'sainnhe/gruvbox-material'

" Bar
Plug 'nvim-lualine/lualine.nvim'
"Plug 'vim-airline/vim-airline'

" Visuals
"Plug 'ap/vim-css-color'
Plug 'NvChad/nvim-colorizer.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Settings
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

" Lua config file
lua require('config')

" theme
source $HOME/.config/nvim/theme.vim

" transparency
highlight Normal ctermbg=none guibg=none
highlight NonText ctermbg=none guibg=none

" common
set number                  " add line numbers
set mouse=a                 " enable mouse click
set hlsearch                " highlight search
set incsearch               " incremental search
set showmatch               " show matching
set ignorecase              " case insensitive
set clipboard=unnamedplus   " using system clipboard

" indent
set noexpandtab     " Use actual tab characters
set tabstop=2       " Display tab characters as 2 columns wide
set shiftwidth=2    " Indent by 2 columns with >>, <<, etc.
set softtabstop=0   " No soft tab emulation; spacebar inserts spaces literally

augroup MyAutoCmds
	autocmd!
	" whitespace cleanup
	autocmd BufWritePre * :%s/\s\+$//e

	" visual feedback for yanks
	autocmd TextYankPost * silent! lua vim.highlight.on_yank()

	" autoindent
	autocmd BufWritePre * if expand('%:t') !~# '\.conf$' | silent! normal! gg=G | endif
augroup END
