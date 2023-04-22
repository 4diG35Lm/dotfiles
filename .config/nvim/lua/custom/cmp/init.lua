require("lazy").setup({
-- cmp plugins 補完エンジン
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "nvim-autopairs",
      "jcha0713/cmp-tw2css",
    },
  },
  { "jcha0713/cmp-tw2css" },
  { "jcha0713/cmp-tw2css" },
  -- bufferを補完
  {  "hrsh7th/cmp-buffer"  },
  -- pathを補完
  {  "hrsh7th/cmp-path"  },
  -- LSPを補完
  {  "hrsh7th/cmp-nvim-lsp"  },

  {  "hrsh7th/cmp-nvim-lua"  },
  -- スニペットエンジン
  {  "hrsh7th/vim-vsnip"  },
  -- スニペットを補完
  {  "hrsh7th/cmp-vsnip"  },
  {  "hrsh7th/cmp-omni"  },
  {  "hrsh7th/cmp-emoji"  },
  {  "hrsh7th/cmp-calc"  },
  {  "yutkat/cmp-mocword" },
  {  "hrsh7th/cmp-cmdline" },
  {
    "mtoohey31/cmp-fish",
    ft = "fish",
  },
  {  "delphinus/cmp-ctags" },
  {  "quangnguyen30192/cmp-nvim-tags" },
  {  "prabirshrestha/vim-lsp" },
  {  "dmitmel/cmp-vim-lsp" },
  {  "andersevenrud/cmp-tmux" },
  {  "ray-x/cmp-treesitter"  },
  {  "amarakon/nvim-cmp-fonts" },
  {
    "romgrk/fzy-lua-native",
    build = "make",
  },
  {  "tzachar/fuzzy.nvim" },
  {
    "tzachar/cmp-fuzzy-path",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "tzachar/fuzzy.nvim",
    }
  },
  {  "tzachar/cmp-tabnine",
    dependencies = {
      {  "hrsh7th/nvim-cmp"  }
    },
    build = "./install.sh",
    config = function()
      require("rc/pluginconfig/cmp-tabnine")
    end,
  },
})

require("cmp/config")
