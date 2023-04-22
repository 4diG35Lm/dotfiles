local status, treesitter = pcall(require, "nvim-treesitter")
if not status then
  return
end

local function ts_disable(_, bufnr)
  return vim.api.nvim_buf_line_count(bufnr) > 5000
end

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

require("nvim-treesitter.configs").setup {
  autotag = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  -- And optionally, disable the conflict warning emitted by plugin
  yati = {
    enable = true,
    default_lazy = false,
    default_fallback = "auto",
    suppress_conflict_warning = true,
  },
  -- A list of parser names, or "all"
  ensure_installed = {
    "c",
    "cpp",
    "css",
    "go",
    "graphql",
    "help",
    "html",
    "javascript",
    "json",
    "json5",
    "lua",
    "markdown",
    "python",
    "regex",
    "rust",
    "sql",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vue",
    "yaml",
    "zig",
    "bash",
    "fish",
    "html",
    "javascript",
    "json",
    "lua",
    "php",
    "python",
    "rust",
    "swift",
    "toml",
    "tsx",
    "yaml",
    "wgsl",
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,
    persist_queries = false,
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { "BufWrite", "CursorHold" },
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "all" },

  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { -- 一部の言語では無効にする
      "lua",
      "ruby",
      "toml",
      "c_sharp",
      "vue",
      "javascript",
      "wgsl",
    },
  },
  indent = { enable = false, disable = { "python" } },
  refactor = {
    highlight_definitions = { enable = false },
    highlight_current_scope = { enable = false },
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "'r", -- mapping to rename reference under cursor
      },
    },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "'d", -- mapping to go to definition of symbol under cursor
        list_definitions = "'D", -- mapping to list all definitions in current file
      },
    },
  },
  textobjects = { -- syntax-aware textobjects
    select = {
      enable = true,
      disable = {},
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["iB"] = "@block.inner",
        ["aB"] = "@block.outer",
        -- use sandwich
        -- ["i"] = "@call.inner",
        -- ["a"] = "@call.outer",
        -- ["a"] = "@comment.outer",
        -- ["iF"] = "@frame.inner",
        -- ["oF"] = "@frame.outer",
        ["ii"] = "@conditional.inner",
        ["ai"] = "@conditional.outer",
        ["il"] = "@loop.inner",
        ["al"] = "@loop.outer",
        ["ip"] = "@parameter.inner",
        ["ap"] = "@parameter.outer",
        -- ["iS"] = "@scopename.inner",
        -- ["aS"] = "@statement.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = { ["'>"] = "@parameter.inner" },
      swap_previous = { ["'<"] = "@parameter.inner" },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
      goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
      goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
      goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
    },
  },
  textsubjects = {
    enable = false,
    -- prev_selection = "Q",
    keymaps = {
      ["."] = "textsubjects-smart",
      ["<Tab>"] = "textsubjects-container-outer",
      ["<S-Tab>"] = "textsubjects-container-inner",
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 300,
    disable = { "cpp" }, -- please disable lua and bash for now
  },
  pairs = {
    enable = true,
    disable = {},
    highlight_pair_events = { "CursorMoved" }, -- when to highlight the pairs, use {} to deactivate highlighting
    highlight_self = true,
    goto_right_end = false, -- whether to go to the end of the right partner or the beginning
    fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
    keymaps = { goto_partner = "'%" },
  },
  matchup = {
    enable = false,
    disable = {},
  },
  endwise = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    config = {
      javascript = {
        __default = "// %s",
        jsx_element = "{/* %s */}",
        jsx_fragment = "{/* %s */}",
        jsx_attribute = "// %s",
        comment = "// %s",
      },
    },
  },
  tree_setter = { enable = true },
  tree_docs = { enable = true },
  vim.keymap.set("n", "<Space>h", "<Cmd>TSHighlightCapturesUnderCursor<CR>"),
}
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
