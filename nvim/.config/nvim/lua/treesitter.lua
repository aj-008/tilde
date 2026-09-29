local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if status_ok then
  configs.setup({
    ensure_installed = { 'rust', 'javascript', 'typescript', 'tsx', 'lua', 'toml', 'c' },
    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",  -- vaf to select whole function
          ["if"] = "@function.inner",  -- vif for just the body
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        goto_next_start = { ["]f"] = "@function.outer" },
        goto_prev_start = { ["[f"] = "@function.outer" },
      },
    },

  })
end
