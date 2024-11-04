vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.tabstop = 2      -- Number of spaces that a <Tab> counts for
		vim.opt_local.shiftwidth = 2   -- Number of spaces for each step of (auto)indent
		vim.opt_local.expandtab = false -- Use actual tab characters instead of spaces
	end,
})

