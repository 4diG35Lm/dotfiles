local overrides = require "custom.configs.overrides"

local fn, _, api = require("custom.core.utils").globals()
---@type NvPluginSpec[]
local plugins = {
  require("custom.cmp.init"),
  require("custom.lsp.init"),
  require("custom.Treesitter.init"),
  require("custom.Telescope.init"),
  -- Override plugin definition options
  -- To make a plugin not be loaded
  { "nvim-lua/plenary.nvim" },
  -- bootstrap
  {  "vim-jp/vimdoc-ja" },
  {
    "jedrzejboczar/possession.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require "custom.configs.possession"
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    ft = { "markdown" },
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/vaults/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
    },
    dependencies = {
     { "nvim-lua/plenary.nvim" },
      { "z3z1ma/nvim-cmp" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require "custom.configs.obsidian"
    end,
  },
  ------------------------------------------------------------
  ---- Library
  --------------------------------
  ---- Vim script Library
  {
    "tpope/vim-repeat",
    event = { "VimEnter" },
  },
  --------------------------------
  ---- Lua Library
  { "nvim-lua/popup.nvim" },
  { "kkharji/sqlite.lua" },
  --------------------------------
  --- Productivity
  ----  Analytics
  {
    "wakatime/vim-wakatime",
    lazy = false,
    event = "VimEnter"
  },
  --  Reading  assistant
  {
    "kristijanhusak/line-notes.nvim",
    event = "VimEnter"
  },
  ---  Comment  out
  {
    "numToStr/Comment.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.productivity.Comment"
    end,
  },
  --------------------------------
  ---- UI
  {
    "tjdevries/colorbuddy.nvim",
    lazy = false,
    config = function()
      require "custom.configs.ui.colorbuddy"
    end,
  },
  {
    "ziontee113/color-picker.nvim",
    lazy = false,
  },
  ----  Window  Separators
  {
    "nvim-zh/colorful-winsep.nvim",
    lazy = false,
    event = { "WinNew" },
    config = function()
      require "custom.configs.ui.colorful-winsep"
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = false,
    event = { "VimEnter" },
    config = function()
      require "custom.configs.ui.dressing"
    end,
  },
  ----  Commandline
  {
    "folke/noice.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
      { "rcarriga/nvim-notify" },
    },
    config = function()
      require "custom.configs.ui.noice"
    end,
  },
  {
    "MunifTanjim/nui.nvim",
    config = function()
      require "custom.configs.ui.nui"
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      require "custom.configs.ui.nvim-notify"
    end,
  },
  -- nerdfont
  {
    "lambdalisue/nerdfont.vim",
    lazy = false,
    config = function()
      require "custom.configs.ui.nerdfont"
    end,
  },
  ---- Font
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      require "custom.configs.ui.nvim-web-devicons"
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require "custom.configs.ui.nvim-scrollbar"
    end,
  },
  {
    "kdheepak/tabline.nvim",
    lazy = false,
    dependencies = {
      {
        "nvim-lualine/lualine.nvim",
        lazy = true,
        config = function()
          require "custom.configs.ui.lualine"
        end,
      },
      { "nvim-tree/nvim-web-devicons", lazy = true },
      { "arkav/lualine-lsp-progress" },
    },
    config = function()
      require "custom.configs..ui.tabline"
    end,
  },
  --  outline
  {
    "beauwilliams/statusline.lua",
    lazy = false,
    config = function()
      require "custom.configs.ui.statusline"
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require "custom.configs.ui.todo-comments"
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    lazy = false,
    version = "*",
    config = function()
      require "custom.configs.ui.toggleterm"
    end,
  },
  {
    'folke/twilight.nvim',
    lazy = false,
    config = function()
      require "custom.configs.ui.twilight"
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = "VimEnter",
    config = function()
      require "custom.configs.ui.vim-illuminate"
    end,
  },

  ----------------------------------
  ---- Theme
  ---- ColorScheme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    name = "kanagawa",
    config = function()
      require "custom.configs.theme.kanagawa"
    end,
  },
  {
    "norcalli/nvim-base16.lua",
    lazy = false,
    priority = 10000,
    name = "base16",
  },
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 10000,
    name = "base16",
    config = function()
      require "custom.configs.theme.nord"
    end,
  },
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 10000,
    name = "catppuccin",
    config = function()
      require "custom.configs.theme.catppuccin"
    end,
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = true,
    name = "vscode"
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
  },
  --------------------------------
  { "Shougo/vimfiler.vim" },
  -- Post-install/update hook with call of vimscript function with argument
  {
    "glacambre/firenvim",
    lazy = false,
    build = function()
      fn["firenvim#install"](0)
    end,
  },
  --------------------------------------------------------------
  ---- FuzzyFinders
  ---- Fzf
  { "junegunn/fzf",
    lazy = false,
    build = "./install --bin"
  },
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
    "mizlan/iswap.nvim",
    event = "VimEnter",
    config = function()
      require "custom.configs.iswap"
    end,
  },
  --------------------------------
  --------------------------------------------------------------
  ----  Appearance
  ----------------------------------
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
    "melkster/modicator.nvim",
    event = "VimEnter"
  },
  --------------------------------
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
  --------------------------------
  ----  Debugger
  {
    "rcarriga/nvim-dap-ui",
    lazy = false,
    config = function()
      require "custom.configs.debugger.nvim-dap-ui"
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    lazy = false,
    config = function()
      require "custom.configs.debugger.nvim-dap-virtual-text"
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
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
          { "williamboman/mason.nvim" },
        },
      },
    },
    config = function()
      require "custom.configs.debugger.nvim-dap"
    end,
  },
  --  ------------------------------------------------------------
  --  --  Editor
  {
    "stevearc/aerial.nvim",
    lazy = false,
    cmd = "AerialToggle",
    config = function()
      require "custom.configs.editor.aerial"
    end,
  },
  {
    "m4xshen/autoclose.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.autoclose"
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VimEnter",
    enabled = function()
      return not vim.g.vscode
    end,
    config = function()
      require "custom.configs.editor.bufferline"
    end,
  },
  ----  Word  Move
  {
    "bkad/CamelCaseMotion",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.CamelCaseMotion"
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require "custom.configs.editor.conform"
    end,
  },
  ----  Horizontal  Move
  {
    "jinh0/eyeliner.nvim",
    event = "VimEnter"
  },
  {
    "MunifTanjim/eslint.nvim",
    lazy = false,
    config = function()
      require "custom.configs.editor.eslint"
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    lazy = false,
  },
  ----  Paste
  {
    "tversteeg/registers.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.registers"
    end,
  },
  --  --  Move
  {
    "phaazon/hop.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.hop"
    end,
  },
  --  indent
  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = false,
    main = "ibl",
    opts = {},
    config = function()
      require "custom.configs.editor.indent-blankline"
    end,
  },
  ----  Jump
  {
    "cbochs/portal.nvim",
    lazy = false,
    event = "VimEnter",
    dependencies = {
      { "cbochs/grapple.nvim" },
    },
    config = function()
      require "custom.configs.editor.portal"
    end,
  },
  ------  Snippet
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = function()
      require "custom.configs.editor.LuaSnip"
    end,
  },
  ----  Snippet  Pack
  {
    "molleweide/LuaSnip-snippets.nvim",
    event = "VimEnter"
  },
  --------------------------------
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require "custom.configs.editor.harpoon"
    end,
  },
  -- Filer
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        lazy = false,
        config = function()
          require "custom.configs.nvim-window-picker"
        end,
      },
      { "nvim-tree/nvim-web-devicons" }, -- not strictly required, but recommended
      { "MunifTanjim/nui.nvim" },
      { "nvim-lua/plenary.nvim" },
      {
        "ThePrimeagen/harpoon",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
        config = function()
          require "custom.configs.editor.harpoon"
        end,
      },
      {
        "s1n7ax/nvim-window-picker",
        config = function()
          require "custom.configs.nvim-window-picker"
        end,
      },
    },
    config = function()
      require "custom.configs.editor.neo-tree"
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    lazy = false,
    config = function()
      require "custom.configs.editor.nvim-autopairs"
    end,
  },
  {
    "m4xshen/smartcolumn.nvim",
    lazy = false,
    config = function()
      require "custom.configs.editor.smartcolumn"
    end,
  },
  ----  Code  outline
  {
    "simrat39/symbols-outline.nvim",
    event = "VimEnter"
  },
  ----  Format
  {
    "cappyzawa/trim.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.trim"
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    cmd = { "TroubleToggle", "Trouble" },
    config = function()
      require "custom.configs.editor.trouble"
    end,
  },
  ----  Vertical  Move
  {
    "haya14busa/vim-edgemotion",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.editor.vim-edgemotion"
    end,
  },
  {
    "dstein64/vim-startuptime",
    lazy = false,
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
  ----------------------------------
  --  Git
  {
    "sindrets/diffview.nvim",
    event = "VimEnter",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function()
      require "custom.configs.git.diffview"
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require "custom.configs.git.lazygit"
    end,
  },
  {
    "f-person/git-blame.nvim",
    lazy = false,
  },
  {
    "akinsho/git-conflict.nvim",
    event = "VimEnter"
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    event = {
       "VimEnter" ,
       "BufRead" ,
    },
    cmd = { "GitSigns" },
    config = function()
      require "custom.configs.git.gitsigns"
    end,
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
  },

  {
    "ggandor/lightspeed.nvim",
    lazy = false,
    event = "VimEnter",
    init = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
  },
  ----------------
  { "yutkat/wb-only-current-line.nvim", event = "VimEnter" },
  --------------------------------
  --  ->  bufferline
  { "Bakudankun/BackAndForward.vim",    event = "VimEnter" },
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
  {
    "deris/vim-rengbang",
    event = "VimEnter"
  },
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
  {
    "yutkat/osc52.nvim",
    event = "VimEnter"
  },
  {
    "yutkat/save-clipboard-on-exit.nvim",
    event = "VimEnter"
  },
  --------------------------------
  {
    "deris/vim-pasta",
    event = "VimEnter"
  },
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
  {
    "lambdalisue/reword.vim",
    event = "VimEnter"
  },
  {
    "haya14busa/vim-metarepeat",
    event = "VimEnter"
  },
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
  {
    "wsdjeg/vim-fetch",
    event = "VimEnter"
  },
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
  ----  Window
  {
    "s1n7ax/nvim-window-picker",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "custom.configs.nvim-window-picker"
    end,
  },
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
  ----  Diff
  {
    "chrisbra/vim-diff-enhanced",
    event = "VimEnter"
  },
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
  {
    "thinca/vim-ambicmd",
    event = "VimEnter"
  },
  {
    "jghauser/mkdir.nvim",
    lazy = false,
    event = "VimEnter",
    config = function()
      require "mkdir"
    end,
  },
  { "yutkat/confirm-quit.nvim", event = "VimEnter" },
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
  ----  Brackets
  {
    "theHamsta/nvim-treesitter-pairs",
    event = "VimEnter"
  },
  --  focus  mode.  Might  not  ever  it.
  {
    "tpope/vim-obsession",
    lazy = false,
  },
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
  {
    "kana/vim-altr",
    event = "VimEnter"
  },
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
  {
    "is0n/jaq-nvim",
    config = function()
      require "custom.configs.jaq"
    end,
    lazy = false,
  },
  {
    "yutkat/taskrun.nvim",
    lazy = false,
    config = function()
      require "custom.configs.taskrun"
    end,
  },
  {
    "airblade/vim-rooter",
    event = "VimEnter"
  },
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
  --  archived
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
  --- lua
  { "nvim-lua/completion-nvim" },
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
  {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
  },
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
  {
    "dhruvasagar/vim-table-mode",
    lazy = false,
    cmd = { "TableModeEnable" },
  },

  --  --------------------------------
  --  --  SQL
  {
    "alcesleo/vim-uppercase-sql",
    event = "VimEnter"
  },
  --------------------------------
  ----  CSV
  ----
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
  --  Rust
  {
    "rust-lang/rust.vim",
    lazy = false,
    ft = { "rust" },
    config = function()
      require "custom.configs.rust"
    end,
  },
  --  Python
  {
    "HiPhish/debugpy.nvim",
    ft = { "python" },
  },
  {
    "wlangstroth/vim-racket",
    ft = { "python" },
    lazy = false,
  },
  -- makrkdown
  {
    "preservim/vim-markdown",
    lazy = false,
    ft = { "markdown" },
    config = function()
      require "custom.configs.vim-markdown"
    end,
  },
  {
    "justinmk/vim-syntax-extra",
    ft = { "python" },
    lazy = false,
  },
  {
    "abhishekmukherg/xonsh-vim",
    ft = { "python" },
    lazy = false,
  },
  --  JS/TS
  {
    "HerringtonDarkholme/yats.vim",
    ft = { "javascript" },
    lazy = false,
  },
  {
    "Quramy/vison",
    ft = { "javascript" },
    lazy = false,
  },
  {
    "jxnblk/vim-mdx-js",
    ft = { "javascript" },
    lazy = false,
  },
  --  HTML
  {
    "posva/vim-vue",
    lazy = false,
  },
  {
    "leafOfTree/vim-svelte-plugin",
    lazy = false,
  },
  --  textedit
  {
    "pedrohdz/vim-yaml-folds",
    lazy = false,
  },
  {
    "mg979/vim-visual-multi",
    lazy = false,
    dependencies = {
      { "kevinhwang91/nvim-hlslens" },
    },
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
  {
    "tjdevries/manillua.nvim",
    event = "VimEnter"
  },
  {
    "bfredl/nvim-luadev",
    event = "VimEnter"
  },
  {
    "folke/neodev.nvim",
    lazy = false
  },
  --  general  plugins
  {
    "Shougo/vimproc.vim",
    lazy = false,
  },
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
  {
    "antoinemadec/FixCursorHold.nvim",
    lazy = false,
  },
  {
    "tpope/vim-rhubarb",
    lazy = false,
  },
  --  filetype
  {
    "nathom/filetype.nvim",
    lazy = false,
    config = function()
      require "custom.configs.filetype"
    end,
  },
  {
    "cespare/vim-toml",
    lazy = false,
  },
  {
    "ocaml/vim-ocaml",
    lazy = false,
  },
  {
    "wlangstroth/vim-racket",
    lazy = false,
  },
  {
    "justinmk/vim-syntax-extra",
    lazy = false,
  },
  {
    "j-hui/fidget.nvim",
    lazy = false,
    config = function()
      require "custom.configs.fidget"
    end,
  },

  {
    "folke/which-key.nvim",
    lazy = false,
  },
  --  -- copilot
  --  {
  --    "github/copilot.vim",
  --    lazy = false,
  --  },
}

return plugins
