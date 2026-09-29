-- Bootstrap lazy.nvim first
require("lazy-bootstrap")

-- Core options before anything else
require("options")

require("matugen-theme").apply()

-- Load plugins via lazy
require("plugins")

-- UI
require("lightline")

-- Editor features
require("keybinds")
require("completion")
require("formatting")
require("treesitter")
require("lsp")
require("circuit-snippets")

-- Tool integrations
require("fzf")
require("latex")
require("stm32-make")


vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    require("matugen-theme").reload()
  end,
})



-- Navigation
vim.keymap.set({'n','x'}, 'm', 'h')
vim.keymap.set({'n','x'}, 'n', 'j')
vim.keymap.set({'n','x'}, 'e', 'k')
vim.keymap.set({'n','x'}, 'i', 'l')

-- Displaced functions → their QWERTY key positions on Colemak-DH
vim.keymap.set({'n','x'}, 'k', 'i')   -- insert (l is where i lives on QWERTY → now free)
vim.keymap.set({'n','x'}, 'j', 'e')   -- end of word
vim.keymap.set({'n','x'}, 'l', 'n')   -- next search result
vim.keymap.set({'n','x'}, 'L', 'N')   -- prev search result
