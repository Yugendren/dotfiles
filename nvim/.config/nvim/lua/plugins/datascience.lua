return {
  -- Jupyter notebook support: run cells inline, see output in nvim
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  -- Send code to a REPL (ipython, python, R, julia, etc.)
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.keymap.set("x", "<leader>cs", "<Plug>SlimeRegionSend", { desc = "Send selection to REPL" })
      vim.keymap.set("n", "<leader>cs", "<Plug>SlimeParagraphSend", { desc = "Send paragraph to REPL" })
      vim.keymap.set("n", "<leader>cc", "<Plug>SlimeLineSend", { desc = "Send line to REPL" })
    end,
  },

  -- CSV/TSV rainbow column highlighting
  {
    "cameron-wags/rainbow_csv.nvim",
    ft = { "csv", "tsv", "csv_semicolon", "csv_whitespace", "csv_pipe", "rfc_csv", "rfc_semicolon" },
    cmd = { "RainbowDelim", "RainbowDelimSimple", "RainbowDelimQuoted", "RainbowMultiDelim" },
    opts = {},
  },
}
