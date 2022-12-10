vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#161616]]
vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#161616]]

local border = {
	{ "╭", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╮", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "╯", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╰", "FloatBorder" },
	{ "│", "FloatBorder" },
}

local icons = require "icons"
local signs = {
	{ name = "DiagnosticSignError", text = icons.diagnostics.Error },
	{ name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
	{ name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
	{ name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
}
for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

local handlers =  {
  ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border}),
  ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border }),
}

-- To instead override globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Customizing how diagnostics are displayed
vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
	-- disable virtual text
	virtual_lines = true,
	-- virtual_text = {
	--   -- spacing = 7,
	--   -- update_in_insert = false,
	--   -- severity_sort = true,
	--   -- prefix = "<-",
	--   prefix = " ●",
	--   source = "if_many", -- Or "always"
	--   -- format = function(diag)
	--   --   return diag.message .. "blah"
	--   -- end,
	-- },

	-- show signs
	signs = {
		active = signs,
	},
	float = {
		focusable = true,
		style = "minimal",
		border = border,
		source = "if_many", -- Or "always"
		header = "",
		prefix = "",
		-- width = 40,
	},
})
