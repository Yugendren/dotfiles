-- Prose writing: distraction-free editing for the manuscript in ~/book.
-- <leader>uz  full zen mode (centred column, nothing else on screen)
-- <leader>up  prose mode toggle (wrap, spell, cursor moves by visual line)

local function prose_on(buf)
  vim.b[buf].prose = true
  local o = vim.opt_local
  o.wrap = true -- wrap long lines...
  o.linebreak = true -- ...at word boundaries, never mid-word
  o.breakindent = true
  o.textwidth = 0 -- one paragraph = one line; let the screen do the breaking
  o.spell = true
  o.spelllang = "en" -- all English variants, so -ise/-ize both pass
  o.conceallevel = 2 -- markview can hide the syntax
  o.colorcolumn = ""
  o.cursorline = false
  o.signcolumn = "no"
  -- Move by what you see, not by what's in the file.
  local m = { buffer = buf, silent = true }
  vim.keymap.set({ "n", "v" }, "j", "gj", m)
  vim.keymap.set({ "n", "v" }, "k", "gk", m)
  vim.keymap.set({ "n", "v" }, "0", "g0", m)
  vim.keymap.set({ "n", "v" }, "$", "g$", m)
end

local function prose_off(buf)
  vim.b[buf].prose = false
  local o = vim.opt_local
  o.wrap = false
  o.spell = false
  o.colorcolumn = "120"
  o.cursorline = true
  o.signcolumn = "yes"
  for _, k in ipairs({ "j", "k", "0", "$" }) do
    pcall(vim.keymap.del, { "n", "v" }, k, { buffer = buf })
  end
end

local function toggle()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].prose then
    prose_off(buf)
  else
    prose_on(buf)
  end
end

vim.api.nvim_create_user_command("Prose", toggle, { desc = "Toggle prose mode" })
vim.keymap.set("n", "<leader>up", toggle, { desc = "Toggle Prose Mode" })

-- Manuscript files open in prose mode automatically; markdown elsewhere doesn't.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("prose_auto", { clear = true }),
  pattern = { vim.fn.expand("~") .. "/book/*.md" },
  callback = function(ev)
    prose_on(ev.buf)
    -- Words you add with `zg` survive across sessions.
    vim.opt_local.spellfile = vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")
  end,
})

return {
  -- The one zen-mode spec. Narrow column, everything else gone.
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" } },
    opts = {
      window = {
        width = 72, -- a readable measure, not a code width
        backdrop = 1,
        options = {
          number = false,
          relativenumber = false,
          cursorline = false,
          signcolumn = "no",
          list = false,
          foldcolumn = "0",
        },
      },
      plugins = {
        options = { showcmd = false, laststatus = 0 },
        twilight = { enabled = true }, -- dim every paragraph but this one
        gitsigns = { enabled = false },
      },
      on_open = function()
        vim.opt_local.colorcolumn = ""
      end,
    },
  },

  -- Dims the paragraphs you aren't in.
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable" },
    keys = { { "<leader>ut", "<cmd>Twilight<cr>", desc = "Toggle Twilight" } },
    opts = { context = 0, treesitter = false }, -- paragraph-level, not syntax-level
  },
}
