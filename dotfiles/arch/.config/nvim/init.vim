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
Plug 'nvimdev/lspsaga.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-tree/nvim-web-devicons'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

source $HOME/.config/nvim/theme.vim

" common
set showmatch               " show matching
set ignorecase              " case insensitive
set hlsearch                " highlight search
set incsearch               " incremental search
set number                  " add line numbers
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard

" transparency
highlight Normal ctermbg=none guibg=none
highlight NonText ctermbg=none guibg=none

" whitespace cleanup
autocmd BufWritePre * :%s/\s\+$//e

" visual feedback for yanks
autocmd TextYankPost * silent! lua vim.highlight.on_yank()

" plugin: autopairs
lua << END
	require("nvim-autopairs").setup({})
END

" plugin: lspsaga
lua << EOF
	require("lspsaga").setup({})
EOF

" autoformat
"autocmd BufWritePre *.js,*.ts,*.py,*.lua :call CocAction('format')
