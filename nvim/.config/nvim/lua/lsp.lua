-- Capabilities from cmp-nvim-lsp
local capabilities = {}
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

-- Configure servers using the new vim.lsp.config API
vim.lsp.config('clangd', {
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--query-driver=/usr/bin/arm-none-eabi-gcc,/usr/bin/arm-none-eabi-g++,/home/ajrom/.platformio/packages/toolchain-xtensa-esp32s3/bin/xtensa-*",
  },
  cmd_env = {
    PATH = "/home/ajrom/.platformio/packages/toolchain-xtensa-esp-elf/bin:" .. vim.env.PATH,
  },
})

vim.lsp.config('ts_ls', {
  capabilities = capabilities,
})

-- Enable them
vim.lsp.enable('clangd')
vim.lsp.enable('ts_ls')

-- Keybinds
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gh", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
