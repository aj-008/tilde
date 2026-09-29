local M = {}

local ok_telescope, telescope = pcall(require, "telescope")
if not ok_telescope then
  vim.notify("circuit_snippets requires telescope.nvim", vim.log.levels.ERROR)
  return M
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Change this to wherever your .tex snippet files actually live.
M.snippets_dir = vim.fn.expand("~/projects/circuitex/entries/")

local function scan_snippets(dir)
  local entries = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return entries
  end
  while true do
    local name, typ = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if typ == "file" and name:match("%.tex$") then
      table.insert(entries, {
        name = name:gsub("%.tex$", ""),
        path = dir .. "/" .. name,
      })
    end
  end
  table.sort(entries, function(a, b)
    return a.name < b.name
  end)
  return entries
end

local function read_snippet_lines(path)
  return vim.fn.readfile(path)
end

--- Opens the picker. `opts` is passed through to telescope as usual.
function M.pick_snippet(opts)
  opts = opts or {}

  local entries = scan_snippets(M.snippets_dir)
  if #entries == 0 then
    vim.notify("No .tex snippets found in " .. M.snippets_dir, vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0) -- {line (1-indexed), col}
  local insert_row = cursor[1] -- 0-indexed row that == "right after the cursor's line"
  local ns = vim.api.nvim_create_namespace("circuit_snippet_preview")

  local mark_id = nil
  local mark_line_count = 0
  local confirmed = false

  -- Removes whatever preview text is currently inserted, restoring the
  -- buffer to exactly what it was before any preview.
  local function remove_preview()
    if not mark_id then
      return
    end
    local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, mark_id, {})
    if pos and #pos > 0 and mark_line_count > 0 then
      local row = pos[1]
      pcall(vim.api.nvim_buf_set_lines, bufnr, row, row + mark_line_count, false, {})
    end
    pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, mark_id)
    mark_id = nil
    mark_line_count = 0
  end

  -- Swaps out any current preview for `lines`, inserted right after the
  -- cursor's original position.
  local function insert_preview(lines)
    remove_preview()
    if #lines == 0 then
      return
    end
    vim.api.nvim_buf_set_lines(bufnr, insert_row, insert_row, false, lines)
    mark_line_count = #lines
    -- Tracks the start of the inserted block; shifts correctly with
    -- unrelated edits above it, though during picking you shouldn't be
    -- editing elsewhere anyway.
    mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, insert_row, 0, {})
  end

  pickers
    .new(opts, {
      prompt_title = "Circuit Snippets (live preview)",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(e)
          return { value = e, display = e.name, ordinal = e.name }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        local function do_preview()
          local selection = action_state.get_selected_entry()
          if not selection then
            remove_preview()
            return
          end
          insert_preview(read_snippet_lines(selection.value.path))
        end

        -- Arrow/Tab movement through the results list.
        actions.move_selection_next:enhance({ post = do_preview })
        actions.move_selection_previous:enhance({ post = do_preview })

        -- Typing in the prompt re-filters the list and can silently
        -- change which entry is "selected" (usually resets to the top
        -- match). Re-sync the preview shortly after each keystroke, once
        -- Telescope's own redraw has settled.
        vim.api.nvim_create_autocmd("TextChangedI", {
          buffer = prompt_bufnr,
          callback = function()
            vim.defer_fn(do_preview, 30)
          end,
        })

        -- Confirm: leave the currently-inserted preview exactly as-is.
        actions.select_default:replace(function()
          confirmed = true
          actions.close(prompt_bufnr)
        end)

        -- Cancel: explicit <Esc> handling so we can distinguish
        -- confirm-close from cancel-close below.
        map({ "i", "n" }, "<esc>", function()
          confirmed = false
          actions.close(prompt_bufnr)
        end)

        actions.close:enhance({
          post = function()
            if not confirmed then
              remove_preview()
            end
          end,
        })

        -- Show a preview for the first entry immediately, before any
        -- explicit move happens.
        vim.schedule(do_preview)

        return true
      end,
    })
    :find()
end

return M
