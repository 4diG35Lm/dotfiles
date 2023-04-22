require("lazy").setup({
--  --------------------------------
--  --  Treesitter
  {  "nvim-treesitter/nvim-treesitter",
    event   =  {
      {  "VimEnter"  },
    },
    build   =  ":TSUpdate",
    dependencies   =  {
      {  "nvim-treesitter/nvim-tree-docs"  },
      {  "vigoux/architext.nvim"  },
      {  "yioneko/nvim-yati"  },
    },
    config   =  function()
      require("rc/pluginconfig/nvim-treesitter")
    end,
  },
  {  "bryall/contextprint.nvim",
    dependencies   =  {
      {  "nvim-treesitter"  },
    },
    config   =  function()
      require("rc/pluginconfig/contextprint")
    end,
  },
  {  "mizlan/iswap.nvim",
    event   =  "VimEnter",
    config   =  function()
      require("rc/pluginconfig/iswap")
    end,
  },

  {  "David-Kunz/treesitter-unit",  event   =  "VimEnter",  },
  --------------------------------
  ----  Treesitter  UI  customize
  {  "haringsrob/nvim_context_vt",  event   =  "VimEnter",  },
  {  "SmiteshP/nvim-gps",
    dependencies   =  {
      {  "nvim-treesitter/nvim-treesitter"  },
    },
    config  =  function()
      require("rc/pluginconfig/nvim-gps")
    end,
  },
  {  "David-Kunz/treesitter-unit",  event   =  "VimEnter",  },
})
