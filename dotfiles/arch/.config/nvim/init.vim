call plug#begin()

" Theme
Plug 'sainnhe/gruvbox-material'

" Bar
Plug 'nvim-lualine/lualine.nvim'
"Plug 'vim-airline/vim-airline'

" Visuals
Plug 'NvChad/nvim-colorizer.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Settings
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

" theme
source $HOME/.config/nvim/theme.vim

" transparency
highlight Normal ctermbg=none guibg=none
highlight NonText ctermbg=none guibg=none

" common
set number
set mouse=a
set showmatch
set ignorecase
set clipboard=unnamedplus

" indent
set tabstop=2
set shiftwidth=2

" au (autocommand)
augroup MyAutoCmds
	autocmd!

	" whitespace cleanup
	autocmd BufWritePre * :%s/\s\+$//e

	" visual feedback for yanks
	autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END

" import lua config
lua require('config')
