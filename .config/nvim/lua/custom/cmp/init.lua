return {
  --------------------------------------------------------------
  ---- LSP & completion
  ----------------------------------
  ----   -- Auto Completion
  {
    "hrsh7th/nvim-cmp",
    event = "VimEnter",
    dependencies = {
      { "cmp-under-comparator" },
      { "L3MON4D3/LuaSnip" },
      { "windwp/nvim-autopairs" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-emoji" },
      { "hrsh7th/cmp-calc" },
      { "f3fora/cmp-spell" },
      { "yutkat/cmp-mocword" },
      { "uga-rosa/cmp-dictionary" },
      { "saadparwaiz1/cmp_luasnip" },
      { "ray-x/cmp-treesitter" },
      { "lukas-reineke/cmp-rg" },
      { "onsails/lspkind.nvim" },
      { "lukas-reineke/cmp-under-comparator" },
      { "weilbith/nvim-lsp-smag" },
      {
        "RishabhRD/nvim-lsputils",
        enabled = false,
        dependencies = {
          { "RishabhRD/popfix" },
        },
      },
      {
        "glepnir/lspsaga.nvim",
        event = "VimEnter",
      },
      { "folke/lsp-colors.nvim" },
      { "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },
      { "ziontee113/color-picker.nvim" },
      {
        "uga-rosa/cmp-dictionary",
        lazy = true,
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
      },
      { "folke/neoconf.nvim" },
      { "quangnguyen30192/cmp-nvim-ultisnips" },
      { "nvim-lua/completion-nvim" },
    },
    config = function()
      require "custom.cmp.config"
    end,
  },
}
