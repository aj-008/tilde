-- Keybinds
local map = vim.keymap.set

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Resize windows
map("n", "<C-Up>", ":resize +2<CR>")
map("n", "<C-Down>", ":resize -2<CR>")
map("n", "<C-Left>", ":vertical resize +2<CR>")
map("n", "<C-Right>", ":vertical resize -2<CR>")



-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")


-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Paste without yanking
map("x", "<leader>p", '"_dP')

-- Delete without yanking
map("n", "<leader>d", '"_d')
map("v", "<leader>d", '"_d')


vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

map("n", "k", function() vim.cmd("startinsert") end)

vim.keymap.set("n", "<leader>ci", function()
  require("circuit_snippets").pick_snippet()
end)
