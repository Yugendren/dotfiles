-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.scrolloff = 8 -- keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- keep 8 columns left/right of cursor
opt.colorcolumn = "120" -- column guide at 120 chars
opt.cursorline = true -- highlight current line
opt.relativenumber = true -- relative line numbers (LazyVim default, ensuring it)
opt.wrap = false -- no line wrapping
opt.conceallevel = 0 -- show all text normally (helps with markdown/json)
opt.clipboard = "unnamedplus" -- yank/paste uses system clipboard
opt.pumblend = 10 -- popup menu transparency
opt.winblend = 10 -- floating window transparency
