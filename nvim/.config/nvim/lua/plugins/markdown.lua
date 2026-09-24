-- ~/.config/nvim/lua/plugins/markdown.lua
return {
  -- Enable LazyVim's built-in markdown extra (LSP, formatter, treesitter parsers)
  { import = "lazyvim.plugins.extras.lang.markdown" },

  -- Disable render-markdown.nvim — it ships with the extra and would fight markview.
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },

  -- Pretty inline rendering: headings, callouts, code blocks, checkboxes, LaTeX
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- recommended by the plugin author
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>um", "<cmd>Markview Toggle<cr>", desc = "Toggle Markdown Render" },
    },
    opts = {
      preview = {
        filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
        ignore_buftypes = {},
        modes = { "n", "no", "c" }, -- render in normal mode, switch to raw in insert
        hybrid_modes = { "i" },     -- show raw markdown only on the line you're editing
      },
    },
  },

  -- Obsidian vault support: [[wiki links]], backlinks, daily notes, tag search
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "research",
          path = "~/Documents/research",
        },
        {
          name = "book",
          path = "~/book", -- [[wiki links]] and backlinks across manuscript notes
        },
      },
      legacy_commands = false,
      ui = { enable = false }, -- let markview handle the visuals
      picker = { name = "snacks.pick" }, -- telescope isn't installed; snacks is
      daily_notes = { folder = "daily" },
    },
  },

  -- Inline image rendering (needs Kitty / WezTerm / Ghostty terminal)
  -- Disabled: Apple Terminal doesn't support inline image protocols.
  -- Switch to Kitty/WezTerm/Ghostty, then flip `enabled = true`.
  {
    "3rd/image.nvim",
    enabled = false,
    ft = { "markdown", "norg" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 100,
      max_height = 12,
    },
  },
}
