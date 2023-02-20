local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	use { 'wbthomason/packer.nvim' } -- Have packer manage itself
	use { 'nvim-treesitter/nvim-treesitter' }
	-- Colorschemes
	use { 'navarasu/onedark.nvim' }

	use { 'nvim-tree/nvim-web-devicons' }
	use { 'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true } }
	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons', -- optional, for file icons
		},
		tag = 'nightly' -- optional, updated every week. (see issue #1193)
	}
	use { 'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons' }
	-- scoping buffers to tabs
	use { 'tiagovla/scope.nvim' }

	-- debug adapter protocol
	use { 'mfussenegger/nvim-dap' }
	use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }

	use { 'nvim-lua/plenary.nvim' }

	-- Package manager for lsp dap etc
	use {
		"williamboman/mason.nvim",
		'williamboman/mason-lspconfig.nvim',
		"jose-elias-alvarez/null-ls.nvim",
		"jayp0521/mason-null-ls.nvim",
	}

	--LSP
	use { 'neovim/nvim-lspconfig' }
	-- Java language server
	use { 'mfussenegger/nvim-jdtls' }

	-- CMP
	use { 'hrsh7th/cmp-nvim-lsp' }
	use { 'hrsh7th/cmp-buffer' }
	use { 'hrsh7th/cmp-path' }
	use { 'hrsh7th/cmp-cmdline' }
	use { 'hrsh7th/nvim-cmp' }
	use { 'onsails/lspkind.nvim' }
	-- For vsnip users.
	-- use { 'hrsh7th/cmp-vsnip' }
	-- use { 'hrsh7th/vim-vsnip' }
	-- For luasnip users.
	use { "L3MON4D3/LuaSnip" }
	use { "rafamadriz/friendly-snippets" }
	use { 'saadparwaiz1/cmp_luasnip' }

	-- Telescope
	use {
		'nvim-telescope/telescope.nvim', branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}
	use { 'nvim-telescope/telescope-dap.nvim' }
	use { 'nvim-telescope/telescope-ui-select.nvim' }
	-- Autopairs
	use {
		"windwp/nvim-autopairs",
		config = function() require("nvim-autopairs").setup {} end
	}
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
