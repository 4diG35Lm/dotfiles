return({
  --------------------------------------------------------------
  ---- LSP & completion
  ----------------------------------
  ---- Language Server Protocol(LSP)
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspLog" },
    event = { "BufReadPre", "BufRead" },
    dependencies = {
      {
        "folke/neoconf.nvim",
        config = function()
          require "custom.lsp.neoconf"
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
          {
            "neovim/nvim-lspconfig",
            lazy = false,
            config = function()
              require "custom.lsp.nvim-lspconfig"
            end,
          },
          {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            lazy = false,
            event = { "FocusLost", "CursorHold" },
            config = function()
              require "custom.lsp.mason-tool-installer"
            end,
          },
        },
        { "weilbith/nvim-lsp-smag" },
        { "nvim-lua/completion-nvim" },
        { "ray-x/lsp_signature.nvim" },
        {
          "tamago324/nlsp-settings.nvim",
          config = function()
            require "custom.lsp.nlsp-settings"
          end,
        },
        --------------------------------
        ---- LSP's UI
        { "nvim-lua/lsp-status.nvim" },
        {
          "mrded/nvim-lsp-notify",
          dependencies = {
            { 'rcarriga/nvim-notify' },
          },
        },
        { "williamboman/mason.nvim" },
        {
          "williamboman/mason-lspconfig.nvim",
          event = "BufReadPre",
        },
      },
      config = function()
        require "custom.lsp.config"
      end,
    },
  },
  {
    "lvimuser/lsp-inlayhints.nvim",
    lazy = false,
  },
  {
    "Afourcat/treesitter-terraform-doc.nvim",
    lazy = false,
  },
  -- override plugin configs
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall" },
    event = { "BufRead", "InsertEnter" },
    build = { ":MasonUpdate" },
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
    },
    dependencies = {
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
    },
    config = function()
      require "custom.lsp.mason"
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim" },
      { "nvimtools/none-ls.nvim" },
    },
  },
})
