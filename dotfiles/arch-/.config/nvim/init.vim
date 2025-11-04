call plug#begin()

" Theme
Plug 'sainnhe/gruvbox-material'

" Bar
Plug 'nvim-lualine/lualine.nvim'
"Plug 'vim-airline/vim-airline'

" Visuals
Plug 'ap/vim-css-color'
Plug 'sheerun/vim-polyglot'
Plug 'nvim-tree/nvim-web-devicons'

" Settings
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'windwp/nvim-autopairs'

call plug#end()

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
set autoindent
set smartindent
set noexpandtab     " Use tabs, not spaces
set tabstop=2       " A tab character is 2 columns wide
set shiftwidth=2    " Indent by 2 columns when using >> or <<
set softtabstop=2   " Makes <Tab> and <Backspace> feel like 2-space steps

augroup MyAutoCmds
	autocmd!
	" autoindent
	autocmd BufWritePre *.c,*.cpp,*.lua silent! normal gg=G

	" whitespace cleanup
	autocmd BufWritePre * :%s/\s\+$//e

	" visual feedback for yanks
	autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup END

" plugin: autopairs
lua << EOF
require("nvim-autopairs").setup({})
EOF
