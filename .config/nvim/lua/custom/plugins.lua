local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {
  -- Override plugin definition options
  --------------------------------
  ---- Language Server Protocol(LSP)
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspLog" },
    event = { "BufReadPre", "BufRead" },
    dependencies = {
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
      {
        "folke/neoconf.nvim",
        config = function()
          require "custom.configs.neoconf"
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
          {
            "neovim/nvim-lspconfig",
            lazy = false,
            config = function()
              require "custom.configs.nvim-lspconfig"
            end,
          },
          {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            lazy = false,
            event = { "FocusLost", "CursorHold" },
            config = function()
              require "custom.configs.mason-tool-installer"
            end,
          },
        },
        { "weilbith/nvim-lsp-smag" },
        { "nvim-lua/completion-nvim" },
        -- hrsh7th/cmp-nvim-lsp-signature-help, hrsh7th/cmp-nvim-lsp-document-symbol
        {
          "ray-x/lsp_signature.nvim",
          config = function()
            require "custom.configs.lsp_signature"
          end,
        },
        {
          "tamago324/nlsp-settings.nvim",
          config = function()
            require "custom.configs.nlsp-settings"
          end,
        },
        --------------------------------
        ---- LSP's UI
        {
          "nvim-lua/lsp-status.nvim",
          config = function()
            require "custom.configs.lsp-status"
          end,
        },
        {
          "williamboman/mason.nvim",
          config = function()
            require "custom.configs.mason"
          end,
        },
        {
          "williamboman/mason-lspconfig.nvim",
          event = "BufReadPre",
          dependencies = {
            { "nvim-lua/lsp_extensions.nvim" },
          },
          config = function()
            require "custom.configs.mason-lspconfig"
          end,
        },
      },
      config = function()
        require "plugins.configs.lspconfig"
        require "custom.lsp.config"
      end, -- Override to setup mason-lspconfig
    },
  },
  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
    config = function()
      require "custom.configs.mason"
    end, -- Override to setup mason-lspconfig
  },
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
      {
        "uga-rosa/cmp-dictionary",
        config = function()
          require "custom.configs.cmp-dictionary"
        end,
      },
      { "saadparwaiz1/cmp_luasnip" },
      { "tzachar/cmp-tabnine", lazy = false, build = "./install.sh" },
      { "ray-x/cmp-treesitter" },
      { "lukas-reineke/cmp-rg" },
      {
        "onsails/lspkind.nvim",
        config = function()
          require "custom.configs.lspkind-nvim"
        end,
      },
      { "lukas-reineke/cmp-under-comparator" },
      { "weilbith/nvim-lsp-smag" },
      {
        "RishabhRD/nvim-lsputils",
        enabled = false,
        dependencies = {
          { "RishabhRD/popfix" },
        },
        config = function()
          require "custom.configs.nvim-lsputils"
        end,
      },
      {
        "glepnir/lspsaga.nvim",
        event = "VimEnter",
        config = function()
          require "custom.configs.lspsaga"
        end,
      },
      {
        "folke/lsp-colors.nvim",
        config = function()
          require "custom.configs.lsp-colors"
        end,
      },
      { "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },
      { "ziontee113/color-picker.nvim" },
      {
        "uga-rosa/cmp-dictionary",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
        lazy = true,
      },
      { "folke/neoconf.nvim" },
    },
  },

  --------------------------------
  --  Treesitter
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
    },
    config = function()
      require "custom.configs.nvim-treesitter"
    end,
  },
  {
    "bryall/contextprint.nvim",
    dependencies = {
      { "nvim-treesitter" },
    },
    config = function()
      require "custom.configs.contextprint"
    end,
  },
  {
    "mizlan/iswap.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.iswap"
    end,
  },

  { "David-Kunz/treesitter-unit", event = "VimEnter" },
  --------------------------------
  ----  Treesitter  UI  customize
  { "haringsrob/nvim_context_vt", event = "VimEnter" },
  {
    "SmiteshP/nvim-gps",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require "custom.configs.nvim-gps"
    end,
  },
  { "David-Kunz/treesitter-unit", event = "VimEnter" },
  --------------------------------
  ---- telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    event = { "VimEnter" },
    cmd = { "Telescope" },
    module_pattern = {
      "^telescope$",
      "^telescope%.builtin$",
      "^telescope%.actions%.",
      "^telescope%.from_entry$",
      "^telescope%.previewers%.",
    },
    dependencies = {
      { "dressing.nvim" },
      { "noice.nvim" },
      { "nvim-web-devicons" },
      { "plenary.nvim" },
      { "popup.nvim" },
      { "project.nvim" },
      { "telescope-file-browser.nvim" },
      { "yanky.nvim" },
      { "trouble.nvim" },
      { "barrett-ruth/telescope-http.nvim" },
      { "nvim-lua/popup.nvim" },
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope-github.nvim",
        config = function()
          require("telescope").load_extension "gh"
        end,
      },
      {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
          require("telescope").load_extension "ui-select"
        end,
      },
      {
        "crispgm/telescope-heading.nvim",
        config = function()
          require("telescope").load_extension "heading"
        end,
      },
      {
        "LinArcX/telescope-changes.nvim",
        config = function()
          require("telescope").load_extension "changes"
        end,
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        config = function()
          require("telescope").load_extension "live_grep_args"
        end,
      },
      {
        "nvim-telescope/telescope-smart-history.nvim",
        config = function()
          require("telescope").load_extension "smart_history"
        end,
        build = function()
          os.execute("mkdir -p " .. vim.fn.stdpath "state" .. "databases/")
        end,
      },
      { "nvim-telescope/telescope-symbols.nvim" },
      {
        "nvim-telescope/telescope-media-files.nvim",
        enabled = function()
          return vim.fn.executable "ueberzug"
        end,
        config = function()
          require("telescope").load_extension "media_files"
        end,
      },
      {
        "nvim-telescope/telescope-project.nvim",
        config = function()
          require("telescope").load_extension "project"
        end,
      },
      {
        "nvim-telescope/telescope-vimspector.nvim",
        config = function()
          require("telescope").load_extension "vimspector"
        end,
      },
      {
        "nvim-telescope/telescope-ghq.nvim",
        config = function()
          require("telescope").load_extension "ghq"
        end,
      },
      {
        "nvim-telescope/telescope-fzf-writer.nvim",
        config = function()
          require("telescope").load_extension "fzf_writer"
        end,
      },
      --I don't want to set items myself
      { "LinArcX/telescope-command-palette.nvim" },
      --> filer
      {
        "nvim-telescope/telescope-file-browser.nvim",
        config = function()
          require("telescope").load_extension "file_browser"
        end,
      },
      {
        "sunjon/telescope-arecibo.nvim",
        rocks = { "openssl", "lua-http-parser" },
        config = function()
          require("telescope").load_extension "arecibo"
        end,
      },
      {
        "LinArcX/telescope-command-palette.nvim",
        config = function()
          require("telescope").load_extension "command_palette"
        end,
      },
      {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = {
          { "mfussenegger/nvim-dap" },
          { "nvim-telescope/telescope.nvim" },
          { "nvim-treesitter/nvim-treesitter" },
        },
      },
      {
        "barrett-ruth/telescope-http.nvim",
        dependencies = {
          { "savq/paq-nvim" },
        },
      },
      {
        "nvim-telescope/telescope-z.nvim",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
          { "nvim-lua/popup.nvim" },
        },
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
      {
        "debugloop/telescope-undo.nvim",
        event = "VimEnter",
        config = function()
          require("telescope").load_extension "undo"
        end,
      },
      { "danielvolchek/tailiscope.nvim" },
      {
        "LukasPietzschmann/telescope-tabs",
        config = function()
          require("telescope-tabs").setup {}
        end,
      },
      {
        "telescope-search-dir-picker.nvim",
        config = function()
          require("telescope").load_extension "search_dir_picker"
        end,
      },
      { "prochri/telescope-all-recent.nvim" },
    },
    config = function()
      require "custom.Telescope.config"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    enable = false,
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- To make a plugin not be loaded
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
  },

  { "nvim-lua/plenary.nvim" },
  -- bootstrap
  { "tani/vim-jetpack", lazy = true },
  { "vim-jp/vimdoc-ja" },
  {
    "rmagatti/auto-session",
    config = function()
      require "custom.configs.auto-session"
    end,
  },
  { "j-hui/fidget.nvim" },
  ------------------------------------------------------------
  ---- Library
  --------------------------------
  ---- Vim script Library
  { "tpope/vim-repeat", event = { "VimEnter" } },
  --------------------------------
  ---- Lua Library
  { "nvim-lua/popup.nvim" },
  { "kkharji/sqlite.lua" },
  {
    "rcarriga/nvim-notify",
    config = function()
      require "custom.configs.nvim-notify"
    end, -- Override to setup mason-lspconfig
  },
  {
    "MunifTanjim/nui.nvim",
    config = function()
      require "custom.configs.nui"
    end, -- Override to setup mason-lspconfig
  },
  --------------------------------
  ---- UI Library
  {
    "stevearc/dressing.nvim",
    lazy = false,
    event = { "VimEnter" },
    config = function()
      require "custom.configs.dressing"
    end, -- Override to setup mason-lspconfig
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require "custom.configs.nvim-scrollbar"
    end, -- Override to setup mason-lspconfig
  },
  ----------------------------------
  ---- ColorScheme
  { "itchyny/lightline.vim" },
  { "shaunsingh/nord.nvim", lazy = false },
  --------------------------------
  ---- Filer
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        lazy = false,
        config = function()
          require "custom.configs.nvim-window-picker"
        end, -- Override to setup mason-lspconfig
      },
      { "nvim-tree/nvim-web-devicons" }, -- not strictly required, but recommended
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require "custom.configs.neo-tree"
    end, -- Override to setup mason-lspconfig
  },
  --------------------------------
  ---- Font
  { "nvim-tree/nvim-web-devicons", lazy = false },
  { "t9md/vim-choosewin" },
  { "Shougo/vimfiler.vim" },
  -- nerdfont
  {
    "lambdalisue/nerdfont.vim",
    lazy = false,
    config = function()
      require "custom.configs.nerdfont"
    end, -- Override to setup mason-lspconfig
  },
  { "lambdalisue/glyph-palette.vim" },
  { "kosayoda/nvim-lightbulb", dependencies = {
    { "antoinemadec/FixCursorHold.nvim" },
  } },
  -- Post-install/update hook with call of vimscript function with argument
  {
    "glacambre/firenvim",
    lazy = false,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    lazy = false,
  },
  --  Editor Config
  { "editorconfig/editorconfig-vim" },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "MunifTanjim/eslint.nvim",
    dependencies = {
      { "jose-elias-alvarez/null-ls.nvim" },
    },
  },
  --------------------------------------------------------------
  ---- FuzzyFinders
  ---- Fzf
  { "junegunn/fzf", lazy = false, build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua", lazy = true },
      { "sqlite.lua" },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },
  {
    "mizlan/iswap.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.iswap"
    end,
  },
  --------------------------------
  ----  Treesitter  UI  customize
  { "haringsrob/nvim_context_vt", event = "VimEnter" },
  {
    "SmiteshP/nvim-gps",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
  },
  { "npxbr/gruvbox.nvim", dependencies = { "tjdevries/colorbuddy.vim" } },
  { "tjdevries/colorbuddy.nvim" },
  { "Shougo/deol.nvim" },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    config = function()
      vim.g.bufferline = { icons = "both" }
    end,
  },
  --  paren)
  { "cohama/lexima.vim" },
  { "machakann/vim-sandwich" },
  --  Text  objects
  { "wellle/targets.vim" },
  --------------------------------------------------------------
  ----  Appearance
  ----------------------------------
  --------------------------------
  ----  Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VimEnter",
    enabled = function()
      return not vim.g.vscode
    end,
    config = function()
      require "custom.configs.bufferline"
    end,
  },
  ----------------------------------
  ------  Syntax
  ----------------------------------
  ----  Highlight
  {
    "xiyaowong/nvim-cursorword",
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-cursorword"
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = "VimEnter",
    config = function()
      require "custom.configs.vim-illuminate"
    end,
  },
  {
    "m00qek/baleia.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.baleia"
    end,
  },
  {
    "t9md/vim-quickhl",
    event = "VimEnter",
    config = function()
      require "custom.configs.vim-quickhl"
    end,
  },
  {
    "Pocco81/HighStr.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.HighStr"
    end,
  },
  {
    "Djancyp/better-comments.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.better-comments"
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require "custom.configs.todo-comments"
    end,
  },
  { "melkster/modicator.nvim", event = "VimEnter" },
  --------------------------------
  ----  Window  Separators
  {
    "nvim-zh/colorful-winsep.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.colorful-winsep"
    end,
  },
  --------------------------------
  ----  Menu
  {
    "sunjon/stylish.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.stylish"
    end,
  },
  --------------------------------
  --------------------------------
  ----  Cursor
  {
    "edluffy/specs.nvim",
    lazy = false,
    cmd = { "SpecsEnable" },
    config = function()
      require "custom.configs.specs"
    end,
  },
  --  ------------------------------------------------------------
  --  --  Editing
  --  --  ------------------------------
  --  --------------------------------
  --  --  Move
  {
    "phaazon/hop.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.hop"
    end,
  },
  ----------------
  ----  Horizontal  Move
  { "jinh0/eyeliner.nvim", event = "VimEnter" },
  {
    "ggandor/lightspeed.nvim",
    lazy = false,
    event = "VimEnter",
    init = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
  },
  ----------------
  ----  Vertical  Move
  {
    "haya14busa/vim-edgemotion",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.vim-edgemotion"
    end,
  },
  ----------------
  ----  Word  Move
  {
    "bkad/CamelCaseMotion",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.CamelCaseMotion"
    end,
  },
  { "yutkat/wb-only-current-line.nvim", event = "VimEnter" },
  --------------------------------
  ----  Jump
  {
    "cbochs/portal.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "cbochs/grapple.nvim" },
    },
    config = function()
      require "custom.configs.portal"
    end,
  },
  --  ->  bufferline
  { "Bakudankun/BackAndForward.vim", event = "VimEnter" },
  ----------------------------------
  ----  Text  Object
  {
    "XXiaoA/ns-textobject.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.ns-textobject"
    end,
  },
  --------------------------------
  ----  Operator
  {
    "gbprod/substitute.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.substitute"
    end,
  },

  {
    "kylechui/nvim-surround",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-surround"
    end,
  },
  -----------------
  ----  Join
  {
    "AckslD/nvim-trevJ.lua",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-trevJ"
    end,
  },
  -----------------
  ----  Adding  and  subtracting
  { "deris/vim-rengbang", event = "VimEnter" },
  {
    "monaqa/dial.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.dial"
    end,
  },
  --------------------------------
  ----  Yank
  {
    "hrsh7th/nvim-pasta",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-pasta"
    end,
  },
  { "yutkat/osc52.nvim", event = "VimEnter" },
  { "yutkat/save-clipboard-on-exit.nvim", event = "VimEnter" },
  --------------------------------
  ----  Paste
  {
    "tversteeg/registers.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.registers"
    end,
  },
  { "deris/vim-pasta", event = "VimEnter" },
  --------------------------------------------------------------
  ----  Search
  ----------------------------------
  ----  Find
  {
    "kevinhwang91/nvim-hlslens",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-hlslens"
    end,
  },
  --------------------------------
  ----  Replace
  { "lambdalisue/reword.vim", event = "VimEnter" },
  { "haya14busa/vim-metarepeat", event = "VimEnter" },
  --------------------------------
  ----  Grep  tool
  {
    "windwp/nvim-spectre",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-spectre"
    end,
  },
  --------------------------------------------------------------
  ----  File  switcher
  ----------------------------------
  ----  Open
  { "wsdjeg/vim-fetch", event = "VimEnter" },
  --------------------------------
  ----  Buffer
  {
    "famiu/bufdelete.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.bufdelete"
    end,
  },
  --------------------------------
  ----  Buffer  switcher
  {
    "stevearc/stickybuf.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.stickybuf"
    end,
  },
  --------------------------------
  ----  Tab
  ----------------------------------
  --  Path  navigation
  { "justinmk/vim-dirvish" },
  --------------------------------
  ----  Window
  {
    "s1n7ax/nvim-window-picker",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-window-picker"
    end,
  },
  --  use  {'andymass/vim-tradewinds',  event   =  "WinNew"  },
  {
    "kwkarlwang/bufresize.nvim",
    lazy = false,
    event = "WinNew",
    config = function()
      require "custom.configs.bufresize"
    end,
  },
  ------------------------------------------------------------
  ----  Standard  Feature  Enhancement
  ----------------------------------
  ----------------------------------
  ----  Diff
  { "chrisbra/vim-diff-enhanced", event = "VimEnter" },
  --------------------------------
  ----  Mark
  {
    "chentoast/marks.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.marks"
    end,
  },
  --  --------------------------------
  --  --  Quickfix
  {
    "kevinhwang91/nvim-bqf",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-bqf"
    end,
  },
  {
    "gabrielpoca/replacer.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.replacer"
    end,
  },
  {
    "stevearc/qf_helper.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.qf_helper"
    end,
  },
  --------------------------------
  ----  Session  --  do  not  use  the  session  per  current  directory
  {
    "jedrzejboczar/possession.nvim",
    lazy = false,
    config = function()
      require "custom.configs.possession"
    end,
  },
  {
    "olimorris/persisted.nvim",
    lazy = false,
    config = function()
      require "custom.configs.persisted"
    end,
  },
  --------------------------------
  ----  SpellCheck  --  ->  null-ls(cspell)  --  https://github.com/neovim/neovim/pull/19419
  {
    "lewis6991/spellsitter.nvim",
    lazy = false,
    dependencies = {
      { "nvim-treesitter" },
    },
    config = function()
      require "custom.configs.spellsitter"
    end,
  },
  ----  Command
  { "thinca/vim-ambicmd", event = "VimEnter" },
  {
    "jghauser/mkdir.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "mkdir"
    end,
  },
  { "sQVe/sort.nvim", cmd = { "Sort" } },
  { "yutkat/confirm-quit.nvim", event = "VimEnter" },
  --------------------------------
  ----  Commandline
  {
    "folke/noice.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require "custom.configs.noice"
    end,
  },
  --------------------------------------------------------------
  ----  New  features
  ----------------------------------
  ----  Translate
  {
    "uga-rosa/translate.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.translate"
    end,
  },
  --------------------------------
  ----  Memo
  --
  {
    "renerocksai/telekasten.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "renerocksai/calendar-vim" },
    },
    config = function()
      require "custom.configs.telekasten"
    end,
  },
  --------------------------------
  ----  Mode  extension
  {
    "anuvyklack/hydra.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "lewis6991/gitsigns.nvim" },
    },
    config = function()
      require "custom.configs.hydra"
    end,
  },
  --------------------------------
  ----  Performance  Improvement
  ----  startup  time  didn't  change  much
  {
    "lewis6991/impatient.nvim",
    lazy = false,
    config = function()
      require "impatient"
    end,
  },
  --------------------------------
  ----  Analytics
  { "wakatime/vim-wakatime", lazy = false, event = "VimEnter" },
  --------------------------------------------------------------
  ----  Coding
  ----------------------------------
  ----  Writing  assistant
  --  Reading  assistant
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.indent-blankline"
    end,
  },
  {
    "glepnir/indent-guides.nvim",
    lazy = false,
    config = function()
      require "custom.configs.indent-guides"
    end,
  },
  { "kristijanhusak/line-notes.nvim", event = "VimEnter" },
  -------------------------------
  ---  Comment  out
  { "tyru/caw.vim" },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.Comment"
    end,
  },
  --------------------------------
  ----  Brackets
  { "theHamsta/nvim-treesitter-pairs", event = "VimEnter" },
  {
    "m4xshen/autoclose.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.autoclose"
    end,
  },
  { "alvan/vim-closetag" },
  --  focus  mode.  Might  not  ever  it.
  { "junegunn/goyo.vim" },
  { "tpope/vim-obsession" },
  --------------------------------
  ----  --  Endwise
  {
    "RRethy/nvim-treesitter-endwise",
    lazy = false,
    event = { "VimEnter", "BufNewFile", "BufRead" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
  },
  --------------------------------
  ----  Code  jump
  { "kana/vim-altr", event = "VimEnter" },
  {
    "rgroli/other.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.other"
    end,
  },
  --------------------------------
  ----  Test
  {
    "klen/nvim-test",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-test"
    end,
  },
  --------------------------------
  ----  Task  runner
  { "stevearc/overseer.nvim", event = "VimEnter" },
  {
    "yutkat/taskrun.nvim",
    lazy = false,
    config = function()
      require "custom.configs.taskrun"
    end,
  },
  ----------------------------------
  ----  Format
  {
    "cappyzawa/trim.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.trim"
    end,
  },
  --------------------------------
  ----  Code  outline
  { "simrat39/symbols-outline.nvim", event = "VimEnter" },
  ----------------------------------
  ------  Snippet
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.LuaSnip"
    end,
  },
  ----  Snippet  Pack
  { "molleweide/LuaSnip-snippets.nvim", event = "VimEnter" },
  { "rafamadriz/friendly-snippets" },
  --------------------------------
  ----  Project
  --   {
  --     "nvim-tree/nvim-tree.lua",
  --     dependencies = {
  --       { "nvim-tree/nvim-web-devicons", lazy = true },
  --     },
  --     tag = "nightly",
  --     lazy = true,
  --     config = function()
  --       require "custom.configs.nvim-tree"
  --     end,
  --   },
  { "airblade/vim-rooter", event = "VimEnter" },
  {
    "klen/nvim-config-local",
    lazy = false,
    config = function()
      require "custom.configs.nvim-config-local"
    end,
  },
  --------------------------------
  ----  Git
  {
    "TimUntersberger/neogit",
    lazy = false,
    event = "BufReadPre",
    config = function()
      require "custom.configs.neogit"
    end,
  },
  { "akinsho/git-conflict.nvim", event = "VimEnter" },
  { "yutkat/convert-git-url.nvim", cmd = { "ConvertGitUrl" } },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.gitsigns"
    end,
  },
  {
    "sindrets/diffview.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.diffview"
    end,
  },
  --------------------------------
  ----  Git  command  assistant
  { "rhysd/committia.vim" },
  --------------------------------
  ----  Debugger
  {
    "rcarriga/nvim-dap-ui",
    lazy = false,
    config = function()
      require "custom.configs.nvim-dap-ui"
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function()
      require "custom.configs.nvim-dap-virtual-text"
    end,
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "rcarriga/nvim-dap-ui" },
      { "theHamsta/nvim-dap-virtual-text" },
      { "nvim-telescope/telescope-dap.nvim" },
    },
    config = function()
      require "custom.configs.nvim-dap"
    end,
  },
  --  archived
  { "Pocco81/DAPInstall.nvim", dependencies = { { "nvim-dap" } } },
  {
    "andrewferrier/debugprint.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.debugprint"
    end,
  },
  --------------------------------
  --  REPL
  {
    "hkupty/iron.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.iron"
    end,
  },
  --------------------------------------------------------------
  ----  Programming  Languages
  ----------------------------------
  ----  JavaScript
  {
    "vuki656/package-info.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.package-info"
    end,
  },
  --------------------------------
  ----  Python
  ----------------------------------
  ----  Rust
  {
    "simrat39/rust-tools.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lspconfig" },
    },
    ft = { "rust" },
    config = function()
      require "custom.configs.rust-tools"
    end,
  },
  --------------------------------
  { "dhruvasagar/vim-table-mode", cmd = { "TableModeEnable" } },

  --  --------------------------------
  --  --  SQL
  { "alcesleo/vim-uppercase-sql", event = "VimEnter" },
  --------------------------------
  ----  CSV
  ----
  { "mechatroner/rainbow_csv", ft = { "csv" } },
  --  buggy
  {
    "chen244/csv-tools.lua",
    lazy = false,
    ft = { "csv" },
    config = function()
      require "custom.configs.csv-tools"
    end,
  },
  --------------------------------
  ----  Json
  { "neoclide/jsonc.vim", ft = { "json", "jsonc" } },
  --  Rust
  { "racer-rust/vim-racer" },
  {
    "rust-lang/rust.vim",
    lazy = false,
    config = function()
      require "custom.configs.rust"
    end,
  },
  --  Python
  { "tmhedberg/SimpylFold", ft = "python" },
  {
    "vim-python/python-syntax",
    ft = "python",
    config = function()
      require "custom.configs.python-syntax"
    end,
  },
  { "vito-c/jq.vim" },
  { "wlangstroth/vim-racket" },
  {
    "preservim/vim-markdown",
    config = function()
      require "custom.configs.vim-markdown"
    end,
  },
  { "justinmk/vim-syntax-extra" },
  { "abhishekmukherg/xonsh-vim" },
  --  JS/TS
  { "MaxMEllon/vim-jsx-pretty" },
  { "elzr/vim-json" },
  { "HerringtonDarkholme/yats.vim" },
  { "antonk52/vim-browserslist" },
  { "Quramy/vison" },
  { "jxnblk/vim-mdx-js" },
  --  HTML
  { "mattn/emmet-vim" },
  { "posva/vim-vue" },
  { "leafOfTree/vim-svelte-plugin" },
  { "skwp/vim-html-escape" },
  --  textedit
  { "pedrohdz/vim-yaml-folds" },
  --  CSS
  { "hail2u/vim-css3-syntax" },
  --  indent
  { "f-person/git-blame.nvim" },
  { "mattn/vim-goimports" },
  { "folke/tokyonight.nvim" },
  { "npxbr/glow.nvim", build = ":GlowInstall" },
  { "mg979/vim-visual-multi", dependencies = { { "kevinhwang91/nvim-hlslens" } } },
  {
    "prettier/vim-prettier",
    config = function()
      require "custom.configs.vim-prettier"
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    lazy = false,
    event = "BufReadPost",
    dependencies = {
      { "kevinhwang91/promise-async" },
    },
    config = function()
      require "custom.configs.nvim-ufo"
    end,
  },
  --  Comment
  {
    "b3nj5m1n/kommentary",
    lazy = false,
    config = function()
      require "custom.configs.kommentary"
    end,
  },
  --  outline
  { "mpeterv/luacheck" },
  {
    "kdheepak/tabline.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lualine/lualine.nvim", lazy = true },
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    config = function()
      require "custom.configs.tabline"
    end,
  },
  { "tjdevries/manillua.nvim", event = "VimEnter" },
  { "bfredl/nvim-luadev", event = "VimEnter" },
  { "folke/neodev.nvim", lazy = false },
  --  general  plugins
  { "Shougo/vimproc.vim" },
  { "Vimjas/vim-python-pep8-indent" },
  { "glidenote/memolist.vim" },
  { "itchyny/vim-qfedit" },
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    event = { "BufRead", "BufNewFile" },
    config = function()
      require "custom.configs.project"
    end,
  },
  {
    "mvllow/modes.nvim",
    lazy = false,
    config = function()
      require "custom.configs.modes"
    end,
  },
  --  Search
  { "romainl/vim-cool" },
  --  Load  on  an  autocommand  event
  { "andymass/vim-matchup", event = "VimEnter" },
  --  Lisps
  { "gpanders/nvim-parinfer" },
  --  Undo  tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
  --  Post-install/update  hook  with  call  of  vimscript  function  with  argument
  { "ziontee113/color-picker.nvim" },
  --  nerdfont
  { "antoinemadec/FixCursorHold.nvim" },
  { "pangloss/vim-javascript" },
  --  Never  remember  what  register  contains  what?  vim-peekaboo  to  the  rescue
  { "junegunn/vim-peekaboo" },
  --  focus  mode.  Might  not  ever  it.
  --  Git
  {
    "dinhhuy258/git.nvim",
    config = function()
      require "custom.configs.git"
    end,
  },
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  { "sgeb/vim-diff-fold" },
  --  auto  format  files.  E.g.  format  js  files  using  typescript.
  { "mhartington/formatter.nvim" },
  { "airblade/vim-gitgutter" },
  { "hrsh7th/nvim-compe" },
  { "mattn/efm-langserver" },
  --  filetype
  {
    "nathom/filetype.nvim",
    lazy = false,
    config = function()
      require "custom.configs.filetype"
    end,
  },
  { "JuliaEditorSupport/julia-vim" },
  { "aklt/plantuml-syntax" },
  { "bfontaine/Brewfile.vim" },
  { "cespare/vim-toml" },
  { "chr4/nginx.vim" },
  { "ekalinin/Dockerfile.vim" },
  { "leafgarland/typescript-vim" },
  { "ocaml/vim-ocaml" },
  { "pest-parser/pest.vim" },
  { "vito-c/jq.vim" },
  { "wlangstroth/vim-racket" },
  { "justinmk/vim-syntax-extra" },
}

return plugins
