local fn, _, api = require("custom.core.utils").globals()
return({
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
      {
        "noice.nvim",
        config = function()
          require("telescope").load_extension "noice"
        end,
      },
      { "nvim-web-devicons" },
      { "plenary.nvim" },
      { "popup.nvim" },
      { "project.nvim" },
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
          os.execute("mkdir -p " .. fn.stdpath "state" .. "databases/")
        end,
      },
      { "nvim-telescope/telescope-symbols.nvim" },
      {
        "nvim-telescope/telescope-media-files.nvim",
        enabled = function()
          return fn.executable "ueberzug"
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
        build =
        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
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
      { "prochri/telescope-all-recent.nvim" },
      {
        "smilovanovic/telescope-search-dir-picker.nvim",
        config = function()
          require("telescope").load_extension "search_dir_picker"
        end,
      },
      {
        "rcarriga/nvim-notify",
        config = function()
          require("telescope").load_extension.notify.notify()
        end,
      },
    },
    config = function()
      require "custom.Telescope.config"
    end,
  },
})
