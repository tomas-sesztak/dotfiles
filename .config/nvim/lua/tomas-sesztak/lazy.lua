local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "tomas-sesztak.plugins" }, { import = "tomas-sesztak.plugins.lsp" } }, {
	change_detection = {
		notify = false,
	},
})

-- set keymaps
local keymap = vim.keymap

keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy" }) -- open lazy
