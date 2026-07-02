return {
  -- add rose-pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main",
      dark_variant = "main",
    },
  },

  -- set rose-pine as the default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}
