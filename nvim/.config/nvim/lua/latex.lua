-- LaTeX / VimTeX
-- Enable vimtex
vim.g.vimtex_enabled = 1

-- Set tex flavor before filetype detection
vim.g.tex_flavor = 'latex'

-- View and compiler settings
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_quickfix_mode = 0

-- Conceal settings
vim.opt.conceallevel = 1
vim.g.tex_conceal = 'abdmg'

-- Keybinds (only set when vimtex loads)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.keymap.set('n', '<leader>lc', '<cmd>VimtexCompile<CR>', { buffer = true })
    vim.keymap.set('n', '<leader>lv', '<cmd>VimtexView<CR>', { buffer = true })
    vim.keymap.set('n', '<leader>lt', '<cmd>VimtexTocToggle<CR>', { buffer = true })
  end
})
