return {
  -- Highlight color codes inline (#ff0000 shows as red)
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        names = false,
        rgb_fn = true,
        hsl_fn = true,
        tailwind = true,
      },
    },
  },

  -- Better diagnostics list
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },

  -- Dim inactive code blocks / unused variables
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = {
      { "<leader>ut", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
    },
    opts = {},
  },

  -- Zen mode for focused editing
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
    opts = {
      window = { width = 120 },
    },
  },

  -- Better marks with visual indicators
  {
    "chentoast/marks.nvim",
    event = "BufReadPre",
    opts = {},
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Undo tree visualizer
  {
    "mbbill/undotree",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
    },
  },
}
