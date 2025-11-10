-- Autopairs
require('nvim-autopairs').setup({})

-- Treesitter
require('nvim-treesitter.configs').setup({
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})

-- Colorizer
require('colorizer').setup({ '*', }, {
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
