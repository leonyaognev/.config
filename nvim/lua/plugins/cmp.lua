vim.api.nvim_set_hl(0, "CmpNormal", { bg = "NONE", fg = "#ebdbb2" })
vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#a89984" })
vim.api.nvim_set_hl(0, "CmpSel", { bg = "#3c3836", fg = "#ebdbb2" })
vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#a89984", italic = true })

return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end,
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			local border = {
				{ "╭", "CmpBorder" },
				{ "─", "CmpBorder" },
				{ "╮", "CmpBorder" },
				{ "│", "CmpBorder" },
				{ "╯", "CmpBorder" },
				{ "─", "CmpBorder" },
				{ "╰", "CmpBorder" },
				{ "│", "CmpBorder" },
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
				window = {
					completion = {
						border = border,
						winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
						col_offset = -3,
						side_padding = 1,
					},
					documentation = {
						border = border,
						winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					kind_icons = {
						Text = "󰉿",
						Method = "󰆧",
						Function = "󰊕",
						Constructor = "",
						Field = "󰜢",
						Variable = "󰀫",
						Class = "󰠱",
						Interface = "",
						Module = "󰏓",
						Property = "󰜢",
						Unit = "󰑭",
						Value = "󰎠",
						Enum = "",
						Keyword = "󰌋",
						Snippet = "",
						Color = "󰏘",
						File = "󰈙",
						Reference = "󰈇",
						Folder = "󰉋",
						EnumMember = "",
						Constant = "󰏿",
						Struct = "󰙅",
						Event = "",
						Operator = "󰆕",
						TypeParameter = "",
					},
					format = function(entry, vim_item)
						local kind_icons = require("cmp").config.window.getkind_icons
								and require("cmp").config.window.getkind_icons()
							or {}
						local kind = vim_item.kind
						if kind_icons[kind] then
							vim_item.kind = kind_icons[kind]
						end
						vim_item.menu = ({
							nvim_lsp = "LSP",
							luasnip = "Snip",
							path = "Path",
							lazydev = "Dev",
						})[entry.source.name]
						return vim_item
					end,
				},
			})
		end,
	},
}
