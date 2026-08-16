local languages = {
	"lua",
	"bash",
	"fish",
	"printf",
	"regex",
	"c",
	"cpp",
	"cmake",
	"rust",
	"go",
	"python",
	"java",
	"kotlin",
	"javascript",
	"typescript",
	"tsx",
	"html",
	"css",
	"scss",
	"vue",
	"c_sharp",
	"sql",
	"dockerfile",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"make",
	"ninja",
	"json",
	"json5",
	"yaml",
	"toml",
	"xml",
	"ini",
	"markdown",
	"markdown_inline",
	"nix",
	"hyprlang",
	"gdscript",
	"csv",
	"diff",
	"ssh_config",
	"requirements",
}

return {
	{
		"stianlyng/neoranger.nvim",
		config = function()
			require("neoranger").setup()
		end,
	},

	{ "ellisonleao/glow.nvim", config = true, cmd = "Glow" },

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})

			ts.install(languages)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = languages,
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
	},

	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					commonlisp = rainbow_delimiters.strategy["local"],
				},
				query = { [""] = "rainbow-delimiters", lua = "rainbow-blocks" },
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	},

	"tpope/vim-sleuth",
	"xiyaowong/transparent.nvim",

	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({
				options = { mode = "buffers", show_buffer_close_icons = false, show_close_icon = false },
			})
		end,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				window = {
					position = "right",
					width = 30,
					mappings = { ["f"] = "focus_preview", ["l"] = "open", ["h"] = "close_node" },
				},
				filesystem = {
					filtered_items = {
						visible = false,
						hide_dotfiles = true,
						hide_hidden = true,
						always_show = { ".gitignore" },
						hide_by_name = { "build", "node_modules" },
					},
					group_empty_dirs = true,
				},
				buffers = { follow_current_file = { enabled = true, leave_dirs_open = true }, group_empty_dirs = true },
			})
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },

		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		},

		keys = {
			{
				"]h",
				function()
					require("gitsigns").nav_hunk("next")
				end,
				desc = "Next Git hunk",
			},
			{
				"[h",
				function()
					require("gitsigns").nav_hunk("prev")
				end,
				desc = "Previous Git hunk",
			},

			{
				"<leader>hp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview hunk",
			},
			{
				"<leader>hr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset hunk",
			},
			{
				"<leader>hb",
				function()
					require("gitsigns").blame_line()
				end,
				desc = "Blame line",
			},
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({ extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() } })
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "tf", builtin.find_files)
			vim.keymap.set("n", "tg", builtin.live_grep)
			vim.keymap.set("n", "tr", builtin.resume)
			vim.keymap.set("n", "tb", builtin.buffers)
			vim.keymap.set("n", "ts", builtin.lsp_document_symbols)
			vim.keymap.set("n", "ti", builtin.lsp_incoming_calls)
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end, { desc = "Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
			end, { desc = "Search in Open Files" })
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Search Neovim files" })
		end,
	},

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("gruvbox")
			vim.cmd.hi("Comment gui=none")
		end,
	},
	{
		"catgoose/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				filetypes = { "*" }, -- все файлы

				options = {
					parsers = {
						hex = { default = true }, -- RGB/RRGGBB и т.д.
						names = {
							enable = true,
						},
						rgb = { enable = true },
						hsl = { enable = true },
						css = true,
						css_fn = true,
					},

					display = {
						mode = "background",
					},
				},
			})
		end,
	},
}
