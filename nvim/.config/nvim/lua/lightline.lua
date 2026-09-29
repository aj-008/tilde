local M = {}

function M.load_matugen_lightline()
  local chunk = loadfile(os.getenv("HOME") .. "/.cache/nvim/colors.lua")
  if not chunk then return end
  local ok, c = pcall(chunk)
  if not ok then return end
  local bg     = { c.background, 0 }
  local fg     = { c.on_background, 15 }
  local accent = { c.primary, 2 }
  local dim    = { c.outline, 8 }
  local err    = { c.error, 1 }
  local warn   = { c.tertiary, 3 }
  local sec    = { c.secondary, 5 }
  vim.g["lightline#colorscheme#matugen#palette"] = vim.fn["lightline#colorscheme#flatten"]({
    normal = {
      left   = { { fg, accent, "bold" }, { fg, dim } },
      middle = { { fg, bg } },
      right  = { { fg, accent, "bold" }, { fg, dim } },
      error  = { { fg, err } },
      warning = { { bg, warn } },
    },
    insert = {
      left   = { { bg, warn, "bold" }, { fg, dim } },
      middle = { { fg, bg } },
      right  = { { bg, warn, "bold" }, { fg, dim } },
    },
    visual = {
      left   = { { bg, sec, "bold" }, { fg, dim } },
      middle = { { fg, bg } },
      right  = { { bg, sec, "bold" }, { fg, dim } },
    },
    replace = {
      left   = { { bg, err, "bold" }, { fg, dim } },
      middle = { { fg, bg } },
      right  = { { bg, err, "bold" }, { fg, dim } },
    },
    inactive = {
      left   = { { dim, bg }, { dim, bg } },
      middle = { { dim, bg } },
      right  = { { dim, bg } },
    },
    tabline = {
      left   = { { fg, dim } },
      tabsel = { { bg, accent, "bold" } },
      middle = { { dim, bg } },
      right  = { { fg, dim } },
    },
  })
  vim.g.lightline = {
    colorscheme = "matugen",
    active = {
      left = {
        { "mode", "paste" },
        { "readonly", "filename", "modified" }
      }
    }
  }
  if vim.fn.exists("*lightline#init") == 1 then
    vim.fn["lightline#init"]()
    vim.fn["lightline#colorscheme"]()
    vim.fn["lightline#update"]()
  end
end

M.load_matugen_lightline()

return M
