-- Autopairs
require('nvim-autopairs').setup({})

-- Colorizer
require('colorizer').setup({ '*' }, {
	RGB      = true,
	RRGGBB   = true,
	RRGGBBAA = true,
	rgb_fn   = true,
	hsl_fn   = true,
	css      = true,
	css_fn   = true,
	names    = true,
	mode     = 'background',
})

-- Treesitter
require('nvim-treesitter').setup({
	install_dir = vim.fn.stdpath('data') .. '/site',
})

-- Auto-enable highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- Auto-enable indentation for all filetypes
vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
