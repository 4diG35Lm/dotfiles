require("lazy").setup({
  --------------------------------------------------------------
  ---- LSP & completion
  ----------------------------------
  ----   -- Auto Completion
  { "hrsh7th/nvim-cmp",
    event = "VimEnter",
    dependencies = {
      { "cmp-under-comparator"  },
      { "L3MON4D3/LuaSnip" },
      { "windwp/nvim-autopairs" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-emoji" },
      { "hrsh7th/cmp-calc" },
      { "f3fora/cmp-spell" },
      { "yutkat/cmp-mocword" },
      { "uga-rosa/cmp-dictionary",
        config   =  function()
          require("rc/pluginconfig/cmp-dictionary")
        end,
      },
      { "saadparwaiz1/cmp_luasnip" },
      {  "tzachar/cmp-tabnine",  build = "./install.sh"  },
      { "ray-x/cmp-treesitter" },
      { "lukas-reineke/cmp-rg" },
      { "onsails/lspkind.nvim",
        config   =  function()
          require("rc/pluginconfig/lspkind-nvim")
        end,
      },
      { "lukas-reineke/cmp-under-comparator"  },
      { "weilbith/nvim-lsp-smag"  },
      { "RishabhRD/nvim-lsputils",
        enabled = false,
        dependencies = {
          {  "RishabhRD/popfix"  },
        },
        config   =  function()
          require("rc/pluginconfig/nvim-lsputils")
        end,
      },
      {  "glepnir/lspsaga.nvim",
        event = "VimEnter",
        config   =  function()
          require("rc/pluginconfig/lspsaga")
        end,
      },
      {  "folke/lsp-colors.nvim",
        config   =  function()
          require("rc/pluginconfig/lsp-colors")
        end,
      },
      {  "https://git.sr.ht/~whynothugo/lsp_lines.nvim"  },
      {  "ziontee113/color-picker.nvim"  },
      {  "uga-rosa/cmp-dictionary",
        dependencies = {
          {  "nvim-lua/plenary.nvim"  },
        },
        lazy = true,
      },
      { "folke/neoconf.nvim"  },
    },
  },
  --------------------------------
  ---- Language Server Protocol(LSP)
  {  "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspLog" },
    event = { "BufReadPre", "BufRead" },
    dependencies = {
      {  "folke/neoconf.nvim",
        config   =  function()
          require("rc/pluginconfig/neoconf")
        end,
      },
      {  "williamboman/mason-lspconfig.nvim",
        dependencies = {
          {  "neovim/nvim-lspconfig",
            config   =  function()
              require("rc/pluginconfig/nvim-lspconfig")
            end,
          },
          {  "WhoIsSethDaniel/mason-tool-installer.nvim",
            event = { "FocusLost", "CursorHold" },
            config   =  function()
              require("rc/pluginconfig/mason-tool-installer")
            end,
        },
      },
      {  "weilbith/nvim-lsp-smag"  },
      {  "nvim-lua/completion-nvim" },
      -- hrsh7th/cmp-nvim-lsp-signature-help, hrsh7th/cmp-nvim-lsp-document-symbol
      {  "ray-x/lsp_signature.nvim",
        config   =  function()
          require("rc/pluginconfig/lsp_signature")
        end,
      },
      {  "tamago324/nlsp-settings.nvim",
        config   =  function()
          require("rc/pluginconfig/nlsp-settings")
        end,
      },
      --------------------------------
      ---- LSP's UI
      {  "nvim-lua/lsp-status.nvim",
        config   =  function()
          require("rc/pluginconfig/lsp-status")
        end,
      },
      {  "williamboman/mason.nvim",
        config   =  function()
          require("rc/pluginconfig/mason")
        end,
      },
      {  "williamboman/mason-lspconfig.nvim",
        event = "BufReadPre",
        dependencies = {
          { 'nvim-lua/lsp_extensions.nvim' },
        },
        config   =  function()
          require("rc/pluginconfig/mason-lspconfig")
        end,
      },
    },
    config = function()
      require("lsp/config")
    end,
    },
  },
})
