local status, ls = pcall(require, "luasnip")
if not status then
  return
end
local s = ls.s
local sn = ls.sn
local isn = ls.indent_snippet_node
local t = ls.t
local i = ls.i
local f = ls.f
local c = ls.c
local d = ls.d
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")
local events = require'luasnip.util.events'
local ai = require'luasnip.nodes.absolute_indexer'
local extras = require("luasnip.extras")

-- ls.loaders.from_vscode.lazy_load {}
-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.
-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
  return args[1]
end

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
  return sn(
    nil,
    c(1, {
      -- Order is important, sn(...) first would cause infinite loop of expansion.
      t(""),
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    })
  )
end

-- complicated function for dynamicNode.
local function jdocsnip(args, _, old_state)
  -- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
  -- Using a restoreNode instead is much easier.
  -- View this only as an example on how old_state functions.
  local nodes = {
    t({ "/**", " * " }),
    i(1, "A short Description"),
    t({ "", "" }),
  }

  -- These will be merged with the snippet; that way, should the snippet be updated,
  -- some user input eg. text can be referred to in the new snippet.
  local param_nodes = {}

  if old_state then
    nodes[2] = i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[2]

  -- At least one param.
  if string.find(args[2][1], ", ") then
    vim.list_extend(nodes, { t({ " * ", "" }) })
  end

  local insert = 2
  for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
    -- Get actual name parameter.
    arg = vim.split(arg, " ", true)[2]
    if arg then
      local inode
      -- if there was some text in this parameter, use it as static_text for this new snippet.
      if old_state and old_state[arg] then
        inode = i(insert, old_state["arg" .. arg]:get_text())
      else
        inode = i(insert)
      end
      vim.list_extend(
        nodes,
        { t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
      )
      param_nodes["arg" .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= "void" then
    local inode
    if old_state and old_state.ret then
      inode = i(insert, old_state.ret:get_text())
    else
      inode = i(insert)
    end

    vim.list_extend(
      nodes,
      { t({ " * ", " * @return " }), inode, t({ "", "" }) }
    )
    param_nodes.ret = inode
    insert = insert + 1
  end

  if vim.tbl_count(args[3]) ~= 1 then
    local exc = string.gsub(args[3][2], " throws ", "")
    local ins
    if old_state and old_state.ex then
      ins = i(insert, old_state.ex:get_text())
    else
      ins = i(insert)
    end
    vim.list_extend(
      nodes,
      { t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
    )
    param_nodes.ex = ins
    insert = insert + 1
  end

  vim.list_extend(nodes, { t({ " */" }) })

  local snip = sn(nil, nodes)
  -- Error on attempting overwrite.
  snip.old_state = param_nodes
  return snip
end

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
  local file = io.popen(command, "r")
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end

-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local date_input = function(args, state, fmt)
  local fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end
-- Every unspecified option will be set to the default.
ls.config.set_config {
  history = true,
  -- Update dynamic snippets in real time.
  updateevents = "TextChanged,TextChangedI",

  -- Autosnippets
  enable_autosnippets = true,

  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "↓", "Error" } },
      },
    },
  },
}
ls.snippet = {
    -- When trying to expand a snippet, luasnip first searches the tables for
  -- each filetype specified in 'filetype' followed by 'all'.
  -- If ie. the filetype is 'lua.c'
  --     - luasnip.lua
  --     - luasnip.c
  --     - luasnip.all
  -- are searched in that order.
  all = {
    -- trigger is fn.
    s("fn", {
      -- Simple static text.
      t("//Parameters: "),
      -- function, first parameter is the function, second the Placeholders
      -- whose text it gets as input.
      f(copy, 2),
      t({ "", "function " }),
      -- Placeholder/Insert.
      i(1),
      t("("),
      -- Placeholder with initial text.
      i(2, "int foo"),
      -- Linebreak
      t({ ") {", "\t" }),
      -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
      i(0),
      t({ "", "}" }),
    }),
    s("class", {
      -- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
      c(1, {
        t("public "),
        t("private "),
      }),
      t("class "),
      i(2),
      t(" "),
      c(3, {
        t("{"),
        -- sn: Nested Snippet. Instead of a trigger, it has a position, just like insert-nodes. !!! These don't expect a 0-node!!!!
        -- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
--         sn(nil, {
--           t("extends "),
--           -- restoreNode: stores and restores nodes.
--           -- pass position, store-key and nodes.
--           r(1, "other_class", i(1)),
--           t(" {"),
--         }),
--         sn(nil, {
--           t("implements "),
--           -- no need to define the nodes for a given key a second time.
--           r(1, "other_class"),
--           t(" {"),
--         }),
      }),
      t({ "", "\t" }),
      i(0),
      t({ "", "}" }),
    }),
    -- Alternative printf-like notation for defining snippets. It uses format
    -- string with placeholders similar to the ones used with Python's .format().
    s(
      "fmt1",
      fmt("To {title} {} {}.", {
        i(2, "Name"),
        i(3, "Surname"),
        title = c(1, { t("Mr."), t("Ms.") }),
      })
    ),
    -- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
    -- Multi-line format strings by default have empty first/last line removed.
    -- Indent common to all lines is also removed. Use the third `opts` argument
    -- to control this behaviour.
    s(
      "fmt2",
      fmt(
        [[
      foo({1}, {3}) {{
        return {2} * {4}
      }}
      ]],
        {
          i(1, "x"),
          rep(1),
          i(2, "y"),
          rep(2),
        }
      )
    ),
    -- Empty placeholders are numbered automatically starting from 1 or the last
    -- value of a numbered placeholder. Named placeholders do not affect numbering.
    s(
      "fmt3",
      fmt("{} {a} {} {1} {}", {
        t("1"),
        t("2"),
        a = t("A"),
      })
    ),
    -- The delimiters can be changed from the default `{}` to something else.
    s(
      "fmt4",
      fmt("foo() { return []; }", i(1, "x"), { delimiters = "[]" })
    ),
    -- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
    s("fmt5", fmta("foo() { return <>; }", i(1, "x"))),
    -- By default all args must be used. Use strict=false to disable the check
    s(
      "fmt6",
      fmt("use {} only", { t("this"), t("not this") }, { strict = false })
    ),
    -- Use a dynamic_node to interpolate the output of a
    -- function (see date_input above) into the initial
    -- value of an insert_node.
    s("novel", {
      t("It was a dark and stormy night on "),
      d(1, date_input, {}, "%A, %B %d of %Y"),
      t(" and the clocks were striking thirteen."),
    }),
    -- Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
    -- Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty string.
    -- This means they are not SELECTed like in other editors/Snippet engines.
    ls.parser.parse_snippet(
      "lspsyn",
      "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"
    ),

    -- When wordTrig is set to false, snippets may also expand inside other words.
    ls.parser.parse_snippet(
      { trig = "te", wordTrig = false },
      "${1:cond} ? ${2:true} : ${3:false}"
    ),

    -- When regTrig is set, trig is treated like a pattern, this snippet will expand after any number.
    ls.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
    -- Using the condition, it's possible to allow expansion only in specific cases.
    s("cond", {
      t("will only expand in c-style comments"),
    }, {
      condition = function(line_to_cursor, matched_trigger, captures)
        -- optional whitespace followed by //
        return line_to_cursor:match("%s*//")
      end,
    }),
    -- there's some built-in conditions in "luasnip.extras.expand_conditions".
    s("cond2", {
      t("will only expand at the beginning of the line"),
    }, {
      condition = conds.line_begin,
    }),
    -- The last entry of args passed to the user-function is the surrounding snippet.
    s(
      { trig = "a%d", regTrig = true },
      f(function(_, snip)
        return "Triggered with " .. snip.trigger .. "."
      end, {})
    ),
    -- It's possible to use capture-groups inside regex-triggers.
    s(
      { trig = "b(%d)", regTrig = true },
      f(function(_, snip)
        return "Captured Text: " .. snip.captures[1] .. "."
      end, {})
    ),
    s({ trig = "c(%d+)", regTrig = true }, {
      t("will only expand for even numbers"),
    }, {
      condition = function(line_to_cursor, matched_trigger, captures)
        return tonumber(captures[1]) % 2 == 0
      end,
    }),
    -- Use a function to execute any shell command and print its text.
    s("bash", f(bash, {}, "ls")),
    -- Short version for applying String transformations using function nodes.
    s("transform", {
      i(1, "initial text"),
      t({ "", "" }),
      -- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
      -- This list will be applied in order to the first node given in the second argument.
      l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
    }),
    s("transform2", {
      i(1, "initial text"),
      t("::"),
      i(2, "replacement for e"),
      t({ "", "" }),
      -- Lambdas can also apply transforms USING the text of other nodes:
      l(l._1:gsub("e", l._2), { 1, 2 }),
    }),
    s({ trig = "trafo(%d+)", regTrig = true }, {
      -- env-variables and captures can also be used:
      l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
    }),
    -- Set store_selection_keys = "<Tab>" (for example) in your
    -- luasnip.config.setup() call to access TM_SELECTED_TEXT. In
    -- this case, select a URL, hit Tab, then expand this snippet.
    s("link_url", {
      t('<a href="'),
      f(function(_, snip)
        return snip.env.TM_SELECTED_TEXT[1] or {}
      end, {}),
      t('">'),
      i(1),
      t("</a>"),
      i(0),
    }),
    -- Shorthand for repeating the text in a given node.
    s("repeat", { i(1, "text"), t({ "", "" }), rep(1) }),
    -- Directly insert the ouput from a function evaluated at runtime.
    s("part", p(os.date, "%Y")),
    -- use matchNodes to insert text based on a pattern/function/lambda-evaluation.
    s("mat", {
      i(1, { "sample_text" }),
      t(": "),
      m(1, "%d", "contains a number", "no number :("),
    }),
    -- The inserted text defaults to the first capture group/the entire
    -- match if there are none
    s("mat2", {
      i(1, { "sample_text" }),
      t(": "),
      m(1, "[abc][abc][abc]"),
    }),
    -- It is even possible to apply gsubs' or other transformations
    -- before matching.
    s("mat3", {
      i(1, { "sample_text" }),
      t(": "),
      m(
        1,
        l._1:gsub("[123]", ""):match("%d"),
        "contains a number that isn't 1, 2 or 3!"
      ),
    }),
    -- `match` also accepts a function, which in turn accepts a string
    -- (text in node, \n-concatted) and returns any non-nil value to match.
    -- If that value is a string, it is used for the default-inserted text.
    s("mat4", {
      i(1, { "sample_text" }),
      t(": "),
      m(1, function(text)
        return (#text % 2 == 0 and text) or nil
      end),
    }),
    -- The nonempty-node inserts text depending on whether the arg-node is
    -- empty.
    s("nempty", {
      i(1, "sample_text"),
      n(1, "i(1) is not empty!"),
    }),
    -- dynamic lambdas work exactly like regular lambdas, except that they
    -- don't return a textNode, but a dynamicNode containing one insertNode.
    -- This makes it easier to dynamically set preset-text for insertNodes.
    s("dl1", {
      i(1, "sample_text"),
      t({ ":", "" }),
      dl(2, l._1, 1),
    }),
    -- Obviously, it's also possible to apply transformations, just like lambdas.
    s("dl2", {
      i(1, "sample_text"),
      i(2, "sample_text_2"),
      t({ "", "" }),
      dl(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
    }),
  },
  lua = {
    s({ trig = "lam" }, {
      t { "function(" },
      i(1),
      t { ")" },
      t { "", "" },
      t { "  " },
      i(0),
      t { "", "" },
      t { "end" },
    }),
--     parse({ trig = "lam" }, {
--       "function(${1})",
--       "\t${0}",
--       "end",
--     }),
  },
  python = {
    s({
      trig = "^#!",
      regTrig = true,
      name = "shebang",
      dscr = "Interpreter directive to execute file with Python",
      snippetType = "autosnippet",
      },
      fmt(
        [[
        #!/usr/bin/env python{}
        ]],
        ls.choice_node(1, {
          ls.text_node({ "" }),
          ls.text_node({ "3" }),
        }, {})
      )
    ),
    s( -- module-level logger
      {
        trig = "logger",
        name = "Global Logger",
        dscr = "A globally scoped module-level logger",
        snippetType = "snippet",
      },
      fmt(
        [[
        logger: logging.Logger = logging.getLogger({})
        {}
        ]],
        {
          ls.insert_node(1, "__name__"),
          ls.choice_node(2, {
            ls.text_node("logger.addHandler(logging.NullHandler())"),
            ls.text_node(""),
          }, {}),
        }
      )
    ),

    s( -- log message
      {
        trig = "lm",
        name = "Log Message (Choice)",
        dscr = "Log a new message to the global logger",
        snippetType = "snippet",
      },
      fmt(
        [[
        logger.{}({})
        ]],
        {
          ls.choice_node(1, {
            ls.text_node("debug"),
            ls.text_node("info"),
            ls.text_node("warning"),
            ls.text_node("error"),
            ls.text_node("critical"),
            ls.text_node("exception"),
          }, {}),
          ls.insert_node(2, "\"message\""),
        }
      )
    ),

--     s( -- class definition
--       {
--         trig = "class",
--         name = "Class Definition",
--         dscr = "Define a new class",
--         snippetType = "snippet",
--       },
--       fmt(
--         [[
--         class {}{}:
--           """{}"""
--           def __init__(self{}):
--             """{}"""
--             {}
--         ]],
--         {
--           ls.insert_node(1, "ClassName"),
--           ls.choice_node(2, {
--             s_node(nil, {
--               ls.text_node("("),
--               ls.insert_node(1, "ParentClass"),
--               ls.text_node(")"),
--             }),
--             ls.text_node(""),
--           }, {}),
--           ls.insert_node(3, "DocString"),
--           ls.choice_node(4, {
--             s_node(nil, {
--               ls.text_node(", "),
--               ls.insert_node(1, "Parameters"),
--             }),
--             ls.text_node(""),
--           }, {}),
--           ls.insert_node(5, "Create a new instance"),
--           ls.insert_node(6, "pass"),
--         }
--       )
--    ),

--     s( -- dataclass definition
--       {
--         trig = "dcl",
--         name = "Dataclass Definition",
--         dscr = "Define a new dataclass",
--         snippetType = "snippet",
--       },
--       fmt(
--         [[
--         @dataclass{}
--         class {}{}:
--           """{}"""
--           {}
--         ]],
--         {
--           ls.choice_node(1, {
--             s_node(nil, {
--               ls.text_node("("),
--               ls.insert_node(1, "Options"),
--               ls.text_node(")"),
--             }),
--             ls.text_node(""),
--           }, {}),
--           ls.insert_node(2, "ClassName"),
--           ls.choice_node(3, {
--             s_node(nil, {
--               ls.text_node("("),
--               ls.insert_node(1, "ParentClass"),
--               ls.text_node(")"),
--             }),
--             ls.text_node(""),
--           }, {}),
--           ls.insert_node(4, "DocString"),
--           ls.insert_node(5, "Attributes"),
--         }
--       )
--     ),

    s( -- function defintion
      {
        trig = "deff",
        name = "Function Definition",
        dscr = "Function definition with docstring",
        snippetType = "snippet",
      },
      fmt(
        [[
        def {}({}) -> {}:
          """{}"""
          {}
        ]],
        {
          ls.insert_node(1, "function_name"),
          ls.insert_node(2, "Parameters"),
          ls.insert_node(3, "None"),
          ls.insert_node(4, "DocString"),
          ls.insert_node(5, "pass"),
        }
      )
    ),

    s( -- method defintion
      {
        trig = "defm",
        name = "Method Definition",
        dscr = "Method definition with docstring",
        snippetType = "snippet",
      },
      fmt(
        [[
        def {}(self, {}) -> {}:
          """{}"""
          {}
        ]],
        {
          ls.insert_node(1, "function_name"),
          ls.insert_node(2, "Parameters"),
          ls.insert_node(3, "None"),
          ls.insert_node(4, "DocString"),
          ls.insert_node(5, "pass"),
        }
      )
    ),

    s( -- property decorator
      {
        trig = "@property",
        name = "Class Property Decorator",
        dscr = "Define a property for a Class",
        snippetType = "snippet",
      },
      fmt(
        [[
        @property
        def {}(self) -> {}:
          """Return the {} property."""
          return self._{}
        @{}.setter
        def {}(self, value: {}) -> None:
          """Set the {} property."""
          self._{} = value
        ]],
        {
          ls.insert_node(1, "PropertyName"),
          ls.insert_node(2, "Type"),
          extras.rep(1),
          extras.rep(1),
          extras.rep(1),
          extras.rep(1),
          extras.rep(2),
          extras.rep(1),
          extras.rep(1),
        }
      )
    ),

    s( -- context manager
      {
        trig = "with",
        name = "Context Manager",
        dscr = "Use a context manager to access a resource",
        snippetType = "snippet",
      },
      fmt(
        [[
        with {} as {}:
          {}
        ]],
        {
          ls.insert_node(1, "expression"),
          ls.insert_node(2, "variable"),
          ls.insert_node(3, "pass"),
        }
      )
    ),

    s( -- try/except
      {
        trig = "try",
        name = "Try/Except",
        dscr = "Try to perform an action; catch and handle exceptions",
        snippetType = "snippet",
      },
      fmt(
        [[
        try:
          {}
        except {} as {}:
          {}
        ]],
        {
          ls.insert_node(1, "expression"),
          ls.insert_node(2, "Exception"),
          ls.insert_node(3, "error"),
          ls.insert_node(4, "pass"),
        }
      )
    ),

    s( -- assert logs
      {
        trig = "al",
        name = "Assert Logs",
        dscr = "Create a context manager to assert that a particular message is logged",
        snippetType = "snippet",
      },
      fmt(
        [[
        with self.assertLogs("{}", {}) as cm:
          {}
        ]],
        {
          ls.insert_node(1, "logger.name"),
          ls.choice_node(2, {
            ls.text_node("logging.DEBUG"),
            ls.text_node("logging.INFO"),
            ls.text_node("logging.WARNING"),
            ls.text_node("logging.ERROR"),
            ls.text_node("logging.CRITICAL"),
            ls.text_node("logging.EXCEPTION"),
          }, {}),
          ls.insert_node(3, "pass"),
        }
      )
    ),

    s( -- assert raises
      {
        trig = "ar",
        name = "Assert Raises",
        dscr = "Create a context manager to assert that a particular Exception is raised",
        snippetType = "snippet",
      },
      fmt(
        [[
        with self.assertRaises({}):
          {}
        ]],
        {
          ls.insert_node(1, "Exception"),
          ls.insert_node(2, "pass"),
        }
      )
    ),
  },
  ext_opts  =  {
  [types.insertNode] = {
    active = {
      hl_group = "GruvboxBlue",
      -- the priorities should be \in [0, ext_prio_increase).
      priority = 1
    }
  },
  [types.choiceNode] = {
    active = {
      hl_group = "GruvboxRed"
      -- priority defaults to 0
      }
    }
  },
  ext_base_prio = 200,
  ext_prio_increase = 2,
  pattern = "LuasnipPreExpand",
  callback = function()
    -- get event-parameters from `session`.
    local snippet = require("luasnip").session.event_node
    local expand_position =
      require("luasnip").session.event_args.expand_pos

    print(string.format("expanding snippet %s at %s:%s",
      table.concat(snippet:get_docstring(), "\n"),
      expand_position[1],
      expand_position[2]
    ))
  end
}

-- autotriggered snippets have to be defined in a separate table, luasnip.autosnippets.
ls.autosnippets = {
  all = {
    s("autotrigger", {
      t("autosnippet"),
    }),
  },
}

-- in a lua file: search lua-, then c-, then all-snippets.
ls.filetype_extend("lua", { "c" })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
ls.filetype_set("cpp", { "c" })

-- One peculiarity of honza/vim-snippets is that the file with the global snippets is _.snippets, so global snippets
-- are stored in `ls.snippets._`.
-- We need to tell luasnip that "_" contains global snippets:
ls.filetype_extend("all", { "_" })

require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only python snippets

require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading

-- Keymaps
-- Expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-.>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-,>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

local get_visual = function(args, parent)
    if (#parent.snippet.env.SELECT_RAW > 0) then
        return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
    else  -- If SELECT_RAW is empty, return a blank insert node
        return sn(nil, i(1))
    end
end
-- autosnippet({ trig='vfor', name='trig', dscr='dscr'},
--     fmt([[
--     for <> in <>:
--         <>
--     ]],
--     { i(1), i(2), d(3, get_visual, {}, {user_args = {"pass"}}) }, -- leave the first table blank; that's for args which we are not using
--     { delimiters='<>' }
-- ))
vim.cmd [[imap <silent><expr> <C-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-k>']]
vim.cmd([[smap <silent><expr> <C-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-k>']])
-- Source this file to reload settings
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/custom/configs/luasnip.lua<CR>")
