-- FZF
local map = vim.keymap.set

map("n", "<C-p>", ":Files<CR>")
map("n", "<leader>ff", ":Files<CR>")
map("n", "<leader>fg", ":GFiles<CR>")
map("n", "<leader>fb", ":Buffers<CR>")
map("n", "<leader>fr", ":Rg<CR>")
map("n", "<leader>fl", ":Lines<CR>")
map("n", "<leader>fh", ":History<CR>")

-- FZF layout
vim.g.fzf_layout = { window = { width = 0.9, height = 0.6 } }
