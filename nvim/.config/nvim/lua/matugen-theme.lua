local M = {}

local cache_path = os.getenv("HOME") .. "/.cache/nvim/colors.lua"

local function load_colors()
  local chunk = loadfile(cache_path)
  if not chunk then
    vim.notify("matugen-theme: could not load " .. cache_path, vim.log.levels.WARN)
    return nil
  end
  local ok, colors = pcall(chunk)
  if not ok then
    vim.notify("matugen-theme: error evaluating colors.lua", vim.log.levels.WARN)
    return nil
  end
  return colors
end

function M.apply()
  local c = load_colors()
  if not c then return end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "matugen"

  local hl = vim.api.nvim_set_hl

  -- Base editor UI
  hl(0, "Normal", { fg = c.on_background, bg = c.background })
  hl(0, "NormalFloat", { fg = c.on_surface, bg = c.surface_container })
  hl(0, "FloatBorder", { fg = c.outline, bg = c.surface_container })
  hl(0, "Cursor", { fg = c.background, bg = c.primary })
  hl(0, "CursorLine", { bg = c.surface_container_high })
  hl(0, "CursorLineNr", { fg = c.primary, bold = true })
  hl(0, "LineNr", { fg = c.outline })
  hl(0, "SignColumn", { bg = c.background })
  hl(0, "ColorColumn", { bg = c.surface_container })
  hl(0, "VertSplit", { fg = c.outline_variant })
  hl(0, "WinSeparator", { fg = c.outline_variant })
  hl(0, "Visual", { bg = c.secondary_container, fg = c.on_secondary_container })
  hl(0, "Search", { bg = c.tertiary_container, fg = c.on_tertiary_container })
  hl(0, "IncSearch", { bg = c.tertiary, fg = c.on_tertiary })
  hl(0, "Pmenu", { fg = c.on_surface, bg = c.surface_container })
  hl(0, "PmenuSel", { fg = c.on_primary_container, bg = c.primary_container })
  hl(0, "PmenuSbar", { bg = c.surface_container_high })
  hl(0, "PmenuThumb", { bg = c.outline })
  hl(0, "StatusLine", { fg = c.on_surface, bg = c.surface_container })
  hl(0, "StatusLineNC", { fg = c.outline, bg = c.surface_container_low })
  hl(0, "TabLine", { fg = c.outline, bg = c.surface_container_low })
  hl(0, "TabLineSel", { fg = c.on_primary_container, bg = c.primary_container })
  hl(0, "Directory", { fg = c.primary })
  hl(0, "NonText", { fg = c.outline })
  hl(0, "WhiteSpace", { fg = c.surface_variant })

  -- Diagnostics
  hl(0, "DiagnosticError", { fg = c.error })
  hl(0, "DiagnosticWarn", { fg = c.tertiary })
  hl(0, "DiagnosticInfo", { fg = c.secondary })
  hl(0, "DiagnosticHint", { fg = c.outline })
  hl(0, "DiagnosticUnderlineError", { sp = c.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = c.tertiary, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = c.secondary, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = c.outline, undercurl = true })

  -- Syntax
  hl(0, "Comment", { fg = c.outline, italic = true })
  hl(0, "Constant", { fg = c.tertiary })
  hl(0, "String", { fg = c.secondary })
  hl(0, "Character", { fg = c.secondary })
  hl(0, "Number", { fg = c.tertiary })
  hl(0, "Boolean", { fg = c.tertiary })
  hl(0, "Identifier", { fg = c.on_background })
  hl(0, "Function", { fg = c.primary, bold = true })
  hl(0, "Statement", { fg = c.primary })
  hl(0, "Conditional", { fg = c.primary })
  hl(0, "Repeat", { fg = c.primary })
  hl(0, "Keyword", { fg = c.primary })
  hl(0, "PreProc", { fg = c.secondary })
  hl(0, "Type", { fg = c.tertiary })
  hl(0, "Special", { fg = c.secondary })
  hl(0, "Underlined", { underline = true })
  hl(0, "Error", { fg = c.on_error, bg = c.error })
  hl(0, "Todo", { fg = c.on_tertiary_container, bg = c.tertiary_container })

  -- Treesitter (link onto the above so plugins that expect @-groups work)
  hl(0, "@variable", { fg = c.on_background })
  hl(0, "@function", { link = "Function" })
  hl(0, "@keyword", { link = "Keyword" })
  hl(0, "@string", { link = "String" })
  hl(0, "@comment", { link = "Comment" })
  hl(0, "@type", { link = "Type" })
  hl(0, "@constant", { link = "Constant" })
  hl(0, "@property", { fg = c.secondary })
  hl(0, "@punctuation.delimiter", { fg = c.outline })
  hl(0, "@punctuation.bracket", { fg = c.outline })

  -- cmp / completion
  hl(0, "CmpItemAbbrMatch", { fg = c.primary, bold = true })
  hl(0, "CmpItemKind", { fg = c.tertiary })
  hl(0, "CmpItemMenu", { fg = c.outline })

-- Broader treesitter coverage
  hl(0, "@keyword.function", { link = "Keyword" })
  hl(0, "@keyword.return", { link = "Keyword" })
  hl(0, "@keyword.operator", { link = "Keyword" })
  hl(0, "@keyword.import", { fg = c.secondary })
  hl(0, "@type.builtin", { link = "Type" })
  hl(0, "@type.qualifier", { link = "Keyword" })
  hl(0, "@constructor", { fg = c.tertiary })
  hl(0, "@variable.parameter", { fg = c.on_surface_variant })
  hl(0, "@variable.builtin", { fg = c.primary, italic = true })
  hl(0, "@function.builtin", { link = "Function" })
  hl(0, "@function.macro", { fg = c.secondary })
  hl(0, "@operator", { fg = c.outline })
  hl(0, "@punctuation.special", { fg = c.outline })
  hl(0, "@field", { fg = c.secondary })
  hl(0, "@module", { fg = c.tertiary })
  hl(0, "@attribute", { fg = c.outline, italic = true })
  hl(0, "@comment.documentation", { link = "Comment" })

  -- rust-analyzer semantic tokens (LSP) often override treesitter — cover these too
  hl(0, "@lsp.type.function", { link = "Function" })
  hl(0, "@lsp.type.method", { link = "Function" })
  hl(0, "@lsp.type.struct", { link = "Type" })
  hl(0, "@lsp.type.enum", { link = "Type" })
  hl(0, "@lsp.type.trait", { fg = c.tertiary })
  hl(0, "@lsp.type.parameter", { fg = c.on_surface_variant })
  hl(0, "@lsp.type.variable", { fg = c.on_background })
  hl(0, "@lsp.mod.readonly", {}) -- keep as-is, avoid greying out consts unexpectedly

  local transparent = { bg = "none" }
  hl(0, "Normal", transparent)
  hl(0, "NormalFloat", transparent)
  hl(0, "FloatBorder", transparent)
  hl(0, "Pmenu", transparent)
  hl(0, "LineNr", transparent)
  hl(0, "SignColumn", transparent)

end

function M.reload()
  M.apply()

  local ok, lightline = pcall(require, "lightline")
  if ok then
    lightline.load_matugen_lightline()
  end

  vim.notify("matugen-theme reloaded")
end

vim.api.nvim_create_user_command("MatugenReload", M.reload, {})

return M
