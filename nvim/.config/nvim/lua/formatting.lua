-- Formatting (clang-format)
local status_ok, conform = pcall(require, "conform")
if not status_ok then
  return
end

conform.setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
  format_on_save = { timeout_ms = 1000, lsp_fallback = true },
})
