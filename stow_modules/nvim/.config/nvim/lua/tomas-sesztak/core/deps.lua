local M = {}

function M.check(name, binaries)
  local missing = {}
  for _, bin in ipairs(binaries) do
    if vim.fn.executable(bin) ~= 1 then
      table.insert(missing, bin)
    end
  end

  if #missing > 0 then
    vim.schedule(function()
      vim.notify(
        string.format("[%s] missing required binaries: %s", name, table.concat(missing, ", ")),
        vim.log.levels.ERROR
      )
    end)
  end

  return missing
end

return M
