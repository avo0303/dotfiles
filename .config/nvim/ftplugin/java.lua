vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.cmdheight = 2 -- more space in the neovim command line for displaying messages

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = '/home/Andrewsha/workspace/.jdtls-workspace/' .. project_name
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local home = os.getenv('HOME')

local config = {
	cmd = {
		'java',
		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.level=ALL',
		'-noverify',
		'-Xmx1G',
		--add-modules=ALL-SYSTEM \
		--add-opens java.base/java.util=ALL-UNNAMED \
		--add-opens java.base/java.lang=ALL-UNNAMED \
		'-jar',
		'/home/Andrewsha/workspace/lib/jdt-language-server-1.9.0-202203031534/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
		'-configuration', '/home/Andrewsha/workspace/lib/jdt-language-server-1.9.0-202203031534/config_linux/',
		'-data', workspace_dir,
	},
	root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
	capabilities = capabilities,
}

config.settings = {
	['java.format.settings.url'] = home .. "/workspace/lib/eclipse-java-google-style.xml",
	['java.format.settings.profile'] = "GoogleStyle",
	java = {
		signatureHelp = { enabled = true };
		contentProvider = { preferred = 'fernflower' };
		completion = {
			favoriteStaticMembers = {
				"org.hamcrest.MatcherAssert.assertThat",
				"org.hamcrest.Matchers.*",
				"org.hamcrest.CoreMatchers.*",
				"org.junit.jupiter.api.Assertions.*",
				"java.util.Objects.requireNonNull",
				"java.util.Objects.requireNonNullElse",
				"org.mockito.Mockito.*"
			}
		};
		sources = {
			organizeImports = {
				starThreshold = 9999;
				staticStarThreshold = 9999;
			};
		};
		codeGeneration = {
			toString = {
				template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
			}
		};
		configuration = {
			runtimes = {
				{
					name = "JavaSE-11",
					path = home .. "/.sdkman/candidates/java/11.0.17-amzn/",
				},
			}
		};
	};
}

-- adding java debug server
config['init_options'] = {
	bundles = {
		vim.fn.glob('/home/Andrewsha/workspace/lib/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.42.0.jar'
			, 1)
	};
}

config['on_attach'] = function(client, bufnr)
	-- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
	-- you make during a debug session immediately.
	-- Remove the option if you do not want that.
	-- You can use the `JdtHotcodeReplace` command to trigger it manually
	require('jdtls').setup_dap({ hotcodereplace = 'auto' })
	require('jdtls.dap').setup_dap_main_class_configs()
end

require('jdtls').start_or_attach(config)

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references() && vim.cmd("copen")<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
-- Java specific
vim.api.nvim_set_keymap("n", "<leader>di", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
-- If using nvim-dap
-- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
-- vim.api.nvim_set_keymap("n", "<leader>dt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
-- vim.api.nvim_set_keymap("n", "<leader>dn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)

vim.api.nvim_set_keymap("v", "<leader>de", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>de", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
vim.api.nvim_set_keymap("v", "<leader>dm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format{async=true}<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
