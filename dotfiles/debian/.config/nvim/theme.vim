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

" set lualine theme
lua << END
	require("lualine").setup({
		options = {
			theme = 'gruvbox-material'
		},
	})
END

colorscheme gruvbox-material
