-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Keep search results centered
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- Paste without losing register
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Quick save
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Open terminal split
map("n", "<leader>th", "<cmd>split | terminal<cr>", { desc = "Terminal (horizontal)" })
map("n", "<leader>tv", "<cmd>vsplit | terminal<cr>", { desc = "Terminal (vertical)" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })
