return ({
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VimEnter" },
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-tree-docs" },
      { "vigoux/architext.nvim" },
      { "yioneko/nvim-yati" },
      { "tree-sitter-javascript" },
      { "tree-sitter/tree-sitter-javascript" },
      { "tree-sitter/tree-sitter-python" },
      { "nvim-treesitter/nvim-treesitter-context" },
      { "HiPhish/nvim-ts-rainbow2" },
    },
    config = function()
      require "custom.Treesitter.config"
    end,
  },
  {
    "mizlan/iswap.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.iswap"
    end,
  },

  { "David-Kunz/treesitter-unit",  event = "VimEnter" },
  --------------------------------
  ----  Treesitter  UI  customize
  { "haringsrob/nvim_context_vt",  event = "VimEnter" },
  { "David-Kunz/treesitter-unit",  event = "VimEnter" },
  --------------------------------
  { "nvim-treesitter/playground" },
  { "theHamsta/nvim-treesitter-pairs" },
})
