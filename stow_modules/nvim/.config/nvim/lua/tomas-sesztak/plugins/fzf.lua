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

  -- We use vim.fn.termopen to run fzf inside the floating window
  vim.fn.termopen(cmd, {
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
  -- Get the list of buffers and join them with newlines
  local bufs = vim.fn.getcompletion('', 'buffer')
  if #bufs == 0 then return end
  local input_data = table.concat(bufs, "\n")

  -- Floating Window UI Logic
  local width = math.ceil(vim.o.columns * 0.8)
  local height = math.ceil(vim.o.lines * 0.8)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.ceil((vim.o.lines - height) / 2),
    col = math.ceil((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded"
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Launch fzf
  local fzf_cmd = string.format("printf '%s' | fzf --reverse --cycle", input_data)

  vim.fn.termopen(fzf_cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        -- Grab the last line (the selection) from the terminal buffer
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local selection = nil

        for i = #lines, 1, -1 do
          if lines[i] ~= "" then
            selection = lines[i]:gsub("%s+$", "") -- Clean trailing whitespace
            break
          end
        end

        vim.api.nvim_win_close(win, true)
        if selection and selection ~= "" then
          vim.cmd("buffer " .. selection)
        end
      else
        -- If user hits ESC or C-c
        vim.api.nvim_win_close(win, true)
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
