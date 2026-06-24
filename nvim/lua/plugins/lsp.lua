return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = { library = { { path = "luvit-meta/library", words = { "vim%.uv" } } } },
	},
	{ "Bilal2453/luvit-meta", lazy = true },

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- LSP attach keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
					map("gr", require("telescope.builtin").lsp_references, "Goto References")
					map("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
					map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd(
							{ "CursorHold", "CursorHoldI" },
							{ buffer = event.buf, group = highlight_augroup, callback = vim.lsp.buf.document_highlight }
						)
						vim.api.nvim_create_autocmd(
							{ "CursorMoved", "CursorMovedI" },
							{ buffer = event.buf, group = highlight_augroup, callback = vim.lsp.buf.clear_references }
						)
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle Inlay Hints")
					end
				end,
			})

			-- Общие capabilities
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			-- LSP сервера
			local servers = {
				lua_ls = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },

				-- TypeScript с Vue plugin
				ts_ls = {
					filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
					init_options = {
						plugins = {
							{
								name = "@vue/typescript-plugin",
								location = vim.fn.stdpath("data")
									.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
								languages = { "vue" },
							},
						},
					},
				},

				-- Vue сервер (template + CSS)
				vue_ls = {},
			}

			-- Mason + установка тулзов
			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(
				ensure_installed,
				{ "stylua", "vue-language-server", "typescript-language-server", "vtsls" }
			)
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			vim.lsp.config("gdscript", {
				cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),

				filetypes = {
					"gd",
					"gdscript",
				},

				root_markers = {
					"project.godot",
				},
			})

			vim.lsp.enable("gdscript")

			-- Автозапуск ts_ls на vue файлах
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "vue",
				callback = function(args)
					local root_dir = vim.fs.root(args.buf, { "package.json", "tsconfig.json", "jsconfig.json" })
					local init_options = {
						plugins = {
							{
								name = "@vue/typescript-plugin",
								location = vim.fn.stdpath("data")
									.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
								languages = { "vue" },
							},
						},
					}

					vim.lsp.start({
						name = "ts_ls",
						cmd = { "typescript-language-server", "--stdio" },
						root_dir = root_dir,
						init_options = init_options,
						capabilities = capabilities,
					})
				end,
			})
		end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true, objc = true }
				return { timeout_ms = 500, lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype] }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				python = { "isort", "black" },
				sql = { "pg_format" },
				markdown = { "prettier" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "prettier" },
				typescriptreact = { "eslint_d" },
				vue = { "prettier" },
			},
		},
	},
}
