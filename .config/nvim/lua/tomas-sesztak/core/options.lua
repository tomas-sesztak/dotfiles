vim.cmd("let g:netrw_liststyle = 3") -- :Explore tree style

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = true

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- highlighting
opt.cursorline = true

-- turn on termguicolors
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light/dark will be dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, EOL or insert mode start position

-- clipboard
--opt.clipboard:append("unnamedplus") -- use system clipboard as default register, enable copy&paste between neovim and system

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- whitespace highlighting
opt.list = true
opt.listchars = { trail = "~", tab = ">~" }

-- settings for MarkDown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.tabstop = 2      -- Number of spaces that a <Tab> counts for
		vim.opt_local.shiftwidth = 2   -- Number of spaces for each step of (auto)indent
		vim.opt_local.expandtab = false -- Use actual tab characters instead of spaces
	end,
})

-- settings for GO
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.tabstop = 2      -- Number of spaces that a <Tab> counts for
		vim.opt_local.shiftwidth = 2   -- Number of spaces for each step of (auto)indent
		vim.opt_local.expandtab = false -- Use actual tab characters instead of spaces
	end,
})

-- settings for .dotfiles
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = os.getenv("HOME") .. "/.dotfiles/*",
	callback = function()
		vim.opt_local.tabstop = 2      -- Number of spaces that a <Tab> counts for
		vim.opt_local.shiftwidth = 2   -- Number of spaces for each step of (auto)indent
		vim.opt_local.expandtab = false -- Use actual tab characters instead of spaces
	end,
})
