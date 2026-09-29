-- STM32 Makefile commands
local function find_make_root()
  local dir = vim.fn.expand('%:p:h')
  
  while dir ~= '/' do
    if vim.fn.filereadable(dir .. '/Makefile') == 1 then
      return dir
    end
    
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end
  
  return nil
end

local function make_at_root(target)
  local root = find_make_root()
  
  if not root then
    vim.api.nvim_err_writeln('Makefile not found in parent directories')
    return
  end
  
  -- Save all buffers
  vim.cmd('wall')
  
  -- Run make command
  local cmd = string.format('cd %s && make %s', vim.fn.fnameescape(root), target)
  vim.cmd('!' .. cmd)
end

-- Keybinds
vim.keymap.set('n', '<leader>mb', function() make_at_root('build') end, { silent = true, desc = 'Make build' })
vim.keymap.set('n', '<leader>mu', function() make_at_root('upload') end, { silent = true, desc = 'Make upload' })
vim.keymap.set('n', '<leader>cd', ':Ex<CR>', { desc = 'Open file explorer' })
