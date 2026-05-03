local ok, spec = pcall(require, "current_theme")
if ok then return spec end
return {
	{ "folke/tokyonight.nvim", priority = 1000 },
	{ "LazyVim/LazyVim", opts = { colorscheme = "tokyonight-night" } },
}
