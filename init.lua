local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	is_bootstrap = true
	vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end

-- require("user.telescope")
require("packer").startup(function(use)
	-- Package manager
	use("wbthomason/packer.nvim")
	-- colorschemes
	use("folke/tokyonight.nvim")
	use({ "ellisonleao/gruvbox.nvim" })

	-- Set colorscheme  -- has to go before lualine otherwise lualine doesn't work, chucking it at the top
	vim.cmd([[colorscheme tokyonight-night]])
	require("tokyonight").setup({
		on_colors = function(colors)
			colors.bg = "#000000"
		end,
	})
	require("tokyonight").load()

	vim.o.termguicolors = true
	require("notify").setup({
		background_colour = "#000000",
	})

	-- LSP Configuration & Plugins
	use({
		"neovim/nvim-lspconfig",
		requires = {
			"williamboman/mason.nvim", -- Automatically install LSPs to stdpath for neovim
			"williamboman/mason-lspconfig.nvim", -- lsp mason stuff
			"j-hui/fidget.nvim", -- Useful status updates for LSP
			"folke/neodev.nvim", -- Additional lua configuration, makes nvim stuff amazing
		},
	})

	-- Autocompletion
	use({ "rafamadriz/friendly-snippets" })
	require("luasnip.loaders.from_vscode").lazy_load()
	use({
		"hrsh7th/nvim-cmp",
		requires = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
	})
	require("luasnip").filetype_extend("javascript", { "javascriptreact" })
	require("luasnip.loaders.from_vscode").lazy_load()

	--Treesitter:Highlight, edit, and navigate code
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			pcall(require("nvim-treesitter.install").update({ with_sync = true }))
		end,
	})
	use({ -- Additional text objects via treesitter
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter",
	})

	-- My plugins
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } }) -- Fancier statusline
	use("lukas-reineke/indent-blankline.nvim") -- Add indentation guides even on blank lines
	use("numToStr/Comment.nvim") -- "gc" to comment visual regions/lines
	require("Comment").setup()
	use("tpope/vim-sleuth") -- Detect tabstop and shiftwidth automatically
	use({ "MunifTanjim/nui.nvim" })
	use({ "rcarriga/nvim-notify" })
	use("mbbill/undotree")
	use("kylechui/nvim-surround")
	use("nvim-tree/nvim-web-devicons")
	use("lewis6991/gitsigns.nvim") -- Git on the side
	use({ "phaazon/hop.nvim" })
	require("hop").setup()
	use({ "akinsho/bufferline.nvim", tag = "v3.*", requires = "nvim-tree/nvim-web-devicons" })
	require("bufferline").setup({ options = { diagnostics = "nvim_lsp" } })
	use("karb94/neoscroll.nvim")
	require("neoscroll").setup({})
	require("indent_blankline").setup({ -- Indentation Lines
		char = "┊",
		show_trailing_blankline_indent = false,
	})
	require("gitsigns").setup({})
	require("neodev").setup() -- Setup neovim lua configuration
	require("fidget").setup() -- Turn on lsp status information

	-- Fuzzy Finder (files, lsp, etc)
	use({ "nvim-telescope/telescope.nvim", branch = "0.1.x", requires = { "nvim-lua/plenary.nvim" } })
	-- makes telescope the default ui viewer
	use({ "nvim-telescope/telescope-ui-select.nvim" })
	-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", cond = vim.fn.executable("make") == 1 })
	-- [[ Configure Telescope ]]
	require("telescope").setup({
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown({
					-- even more opts
				}),
			},
		},
	})
	-- Enable telescope fzf native, if installed
	pcall(require("telescope").load_extension, "fzf")
	require("telescope").load_extension("ui-select")

	-- LSP diagnostics injection, mostly for linting
	use({ "jose-elias-alvarez/null-ls.nvim" })
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = {
			null_ls.builtins.formatting.stylua,
			--null_ls.builtins.diagnostics.eslint.with({ method = null_ls.methods.DIAGNOSTICS_ON_SAVE, }),
			null_ls.builtins.formatting.eslint_d,
		},
	})

	-- ESLint jazz
	use({ "MunifTanjim/eslint.nvim" })
	require("eslint").setup({
		bin = "eslint",
		code_actions = {
			enable = true,
			apply_on_save = {
				enable = false,
				types = { "directive", "problem", "suggestion", "layout" },
			},
			disable_rule_comment = {
				enable = true,
				location = "separate_line", -- or `same_line`
			},
		},
		diagnostics = {
			enable = true,
			report_unused_disable_directives = false,
			run_on = "type", -- or `save`
		},
	})

	-- fancy commandline
	use({ "folke/noice.nvim" })
	require("noice").setup({
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
	})

	if is_bootstrap then
		require("packer").sync()
	end
end)

-- Set lualine as statusline
require("lualine").setup({
	options = {
		theme = "ayu_dark",
		path = 1,
	},
})

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
	print("==================================")
	print("    Plugins are being installed")
	print("    Wait until Packer completes,")
	print("       then restart nvim")
	print("==================================")
	return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	command = "source <afile> | silent! LspStop | silent! LspStart | PackerCompile",
	group = packer_group,
	pattern = vim.fn.expand("$MYVIMRC"),
})

-- [[ Setting options ]]
-- Set highlight on search
vim.o.hlsearch = false
-- Make line numbers default
vim.wo.number = true
-- Enable mouse mode
vim.o.mouse = "a"
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"
-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"
-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- See `:help telescope.builtin`
-- remaps
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").git_files, { desc = "[F]ind in [G]it files" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>fr", require("telescope.builtin").oldfiles, { desc = " [F]ind [r]ecently opened files" })
vim.keymap.set("n", "<leader>fa", require("telescope.builtin").find_files, { desc = " [F]ind [a]ll files" })
vim.keymap.set("n", "<leader>sfd", ":lua require'telescope.builtin'.diagnostics{bufnr=0} <CR>", { desc = " tst desdc" })
vim.keymap.set("n", "<leader>ad", require("telescope.builtin").diagnostics, { desc = " tst desdc" })
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find existing [B]uffers" })
vim.keymap.set("n", "<leader>jl", require("telescope.builtin").jumplist, { desc = "Find existing [B]uffers" })
vim.keymap.set("n", "<leader>ud", ":UndotreeToggle<CR>", { desc = "[U]ndo [T]ree" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame" })
vim.keymap.set("n", "<leader><leader>", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })
vim.keymap.set("n", "<leader>sd", ":lua vim.diagnostic.open_float({'line'}) <CR>")
vim.keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>")
vim.keymap.set("n", ";", ":Format<CR> :w<CR>", { silent = true })
vim.keymap.set("n", "f", ":HopChar2<CR>")
vim.keymap.set("i", "kj", "<Esc>l")
vim.keymap.set("n", "<C-l>", ":bn<CR>", { silent = true })
vim.keymap.set("n", "<C-h>", ":bp<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":bd<CR>", { silent = true })

-- clipboard shortcuts :D
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')

vim.keymap.set("n", "/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "[/] Fuzzily search in current buffer]" })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require("nvim-treesitter.configs").setup({
	-- Add languages to be installed here that you want installed for treesitter
	ensure_installed = { "c", "cpp", "go", "lua", "python", "rust", "typescript", "help", "graphql" },

	highlight = { enable = true },
	indent = { enable = true, disable = { "python" } },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<c-backspace>",
		},
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- you can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
})

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gd", ":Telescope lsp_definitions<cr>", "[G]oto [D]efintion")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format({ timeout_ms = 2000 })
	end, { desc = "Format current buffer with LSP" })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	tsserver = {},
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require("mason").setup()

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
		})
	end,
})

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
})
-- for some reason my tabs were resetting
vim.opt.tabstop = 2
