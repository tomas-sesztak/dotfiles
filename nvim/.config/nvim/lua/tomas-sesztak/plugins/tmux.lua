local M = {}

require("tomas-sesztak.core.deps").check("tmux.lua", { "tmux" })

function M.move(direction)
  local old_win = vim.api.nvim_get_current_win()

  -- Map h,j,k,l to Neovim's window movement commands
  local win_cmd = { h = 'h', j = 'j', k = 'k', l = 'l' }
  vim.cmd('wincmd ' .. win_cmd[direction])

  -- If the window ID is still the same, we didn't move
  if old_win == vim.api.nvim_get_current_win() then
    local tmux_dir = { h = 'L', j = 'D', k = 'U', l = 'R' }
    -- Execute the tmux command via a system call
    os.execute('tmux select-pane -' .. tmux_dir[direction])
  end
end

return M
