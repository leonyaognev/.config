vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("i", "jk", "<Esc>")

vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

vim.keymap.set("n", "gt", "<cmd>BufferLineCycleNext<CR>")
vim.keymap.set("n", "gT", "<cmd>BufferLineCyclePrev<CR>")
vim.keymap.set("n", "gc", "<cmd>bd<CR>")

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>rc", function()
	require("neoranger").toggleFloat()
end, { desc = "Open ranger" })

vim.keymap.set("n", "<leader>rr", function()
	require("neoranger").toggleFloat({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Ranger in file dir" })
