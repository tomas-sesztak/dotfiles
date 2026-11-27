local M = {}

-- Plugin configuration defaults
M.config = {
  border = 'rounded',
  width = 0.85,
  height = 0.8,
  fzf_command = "fzf --color=16 --ansi --preview 'less {}'",
  rg_command = "rg --line-number --no-heading --color=never --smart-case . |fzf --color=16 --ansi |cut -d: -f1"
}

function M.run(mode)
  local commands = {
    ["fzf"] = M.config.fzf_command,
    ["rg"] = M.config.rg_command,
  }

  local cmd = commands[mode]

  if not cmd then
    vim.notify(
      string.format("FZF Error: Mode '%s' is not supported. Use 'fzf' or 'rg'.", tostring(mode)),
      vim.log.levels.ERROR
    )
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)

  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * M.config.width)
  local height = math.floor(vim.o.lines * M.config.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = M.config.border,
  }

  -- Open the floating window
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  local stdout_data = ""

  -- Run fzf in a terminal inside the floating window
  vim.fn.jobstart(cmd, {
    term = true,
    on_stdout = function(_, data)
      -- We keep track of the last non-empty line emitted
      for _, line in ipairs(data) do
        if line ~= "" then
          stdout_data = line
        end
      end
    end,
    on_exit = function(_, exit_code)
      -- Close the window immediately on exit
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end

      -- Exit code 0 means the user selected a file with Enter
      if exit_code == 0 and stdout_data ~= "" then
        local clean = stdout_data:gsub('\x1b%[[0-9;?]*[a-zA-Z]', '')
        clean = clean:gsub('[%c]', '')
        clean = clean:match("^%s*(.-)%s*$")

        if clean and clean ~= "" then
          vim.schedule(function()
            -- Final check: does the file actually exist?
            if vim.fn.filereadable(clean) == 1 then
              vim.cmd('edit ' .. vim.fn.fnameescape(clean))
            else
              -- If it still has crap, this will tell us exactly what is left
              print("FZF error: File not found or path corrupted: " .. clean)
            end
          end)
        end
      end
    end
  })

  vim.cmd('startinsert')
end

function M.fzf_buffer_picker()
  local lines = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if vim.bo[b].buflisted and name ~= "" then
      table.insert(lines, b .. "\t" .. vim.fn.fnamemodify(name, ":~:."))
    end
  end
  if #lines == 0 then return end

  local input, output = vim.fn.tempname(), vim.fn.tempname()
  vim.fn.writefile(lines, input)

  local width = math.ceil(vim.o.columns * 0.8)
  local height = math.ceil(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.ceil((vim.o.lines - height) / 2),
    col = math.ceil((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded"
  })

  -- buffer names reach fzf only via files, never the shell string
  vim.fn.jobstart({
    "sh", "-c",
    [[fzf --reverse --cycle --delimiter '\t' --with-nth 2 --preview 'less {2}' <"$1" >"$2"]],
    "_", input, output,
  }, {
    term = true,
    on_exit = function(_, exit_code)
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      local picked = exit_code == 0 and vim.fn.readfile(output)[1]
      os.remove(input)
      os.remove(output)
      local target = picked and tonumber(picked:match("^(%d+)\t"))
      if target and vim.api.nvim_buf_is_valid(target) then
        vim.api.nvim_set_current_buf(target)
      end
    end
  })

  vim.cmd("startinsert")
end

function M.setup(user_opts)
  require("tomas-sesztak.core.deps").check("fzf.lua", { "fzf", "rg" })

  -- Merge any user-provided options
  M.config = vim.tbl_deep_extend("force", M.config, user_opts or {})

  -- Bind the keymaps
  vim.keymap.set('n', '<leader>ff', function() M.run("fzf") end, {
    desc = 'Fuzzy file name search',
    silent = true,
  })
  vim.keymap.set('n', '<leader>fs', function() M.run("rg") end, {
    desc = 'Fuzzy file content search',
    silent = true,
  })
  vim.keymap.set('n', '<leader>fb', function() M.fzf_buffer_picker() end, {
    desc = 'Fuzzy buffer switcher',
    silent = true,
  })
end

return M
