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

-- On open: install the parser if missing, then highlight and use its indent rules
local function ts_start(buf, lang)
	if not vim.api.nvim_buf_is_valid(buf) then return end
	pcall(vim.treesitter.start, buf, lang)
	local ok, query = pcall(vim.treesitter.query.get, lang, 'indents')
	if ok and query then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		if not lang then return end
		local ok, loaded = pcall(vim.treesitter.language.add, lang)
		if ok and loaded then return ts_start(ev.buf, lang) end
		pcall(function()
			local ts = require('nvim-treesitter')
			if vim.list_contains(ts.get_available(), lang) then
				ts.install(lang):await(function()
					vim.schedule(function() ts_start(ev.buf, lang) end)
				end)
			end
		end)
	end,
})

-- Fix every indent on save, for all filetypes
vim.api.nvim_create_autocmd('BufWritePre', {
	pattern = '*',
	callback = function(ev)
		if not vim.bo[ev.buf].modifiable or vim.bo[ev.buf].buftype ~= '' then return end
		local view = vim.fn.winsaveview()
		vim.cmd('silent! keepjumps normal! gg=G')
		vim.fn.winrestview(view)
	end,
})

-- Clipboard
vim.g.clipboard = {
	name = 'OSC 52',
	copy = {
		['+'] = require('vim.ui.clipboard.osc52').copy('+'),
		['*'] = require('vim.ui.clipboard.osc52').copy('*'),
	},
	paste = {
		['+'] = require('vim.ui.clipboard.osc52').paste('+'),
		['*'] = require('vim.ui.clipboard.osc52').paste('*'),
	},
}
vim.opt.clipboard = 'unnamedplus'
