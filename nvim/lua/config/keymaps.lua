-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local map = vim.keymap.set

map("n", "<S-Enter>", "O<ESC>", { desc = "Add space before" })
map("n", "<Enter>", "o<ESC>", { desc = "Add space after" })

map("n", "<leader>sx", require("telescope.builtin").resume, { noremap = true, silent = true, desc = "Resume" })

map("n", "<C-d>", "<C-d>zz", { silent = true })
map("n", "<C-u>", "<C-u>zz", { silent = true })
map("n", "n", "nzzzv", { silent = true })
map("n", "N", "Nzzzv", { silent = true })
map("n", "H", "zH", { silent = true })
map("v", "H", "zH", { silent = true })
map("n", "L", "zL", { silent = true })
map("v", "L", "zL", { silent = true })
