-- simply use a global function to demo
local status, ufo = pcall(require, "ufo")
if (not status) then return end
function _G.nN(c)
    local ok, msg = pcall(vim.cmd, 'norm!' .. vim.v.count1 .. c)
    if not ok then
        vim.api.nvim_echo({{msg:match(':(.*)$'), 'ErrorMsg'}}, false, {})
        return
    end
    require('hlslens').start()
    ufo.peekFoldedLinesUnderCursor()
end
vim.api.nvim_set_keymap('n', 'n', '<Cmd>lua _G.nN("n")<CR>', {})
vim.api.nvim_set_keymap('n', 'N', '<Cmd>lua _G.nN("N")<CR>', {})
---@diagnostic disable: unused-local, unused-function, undefined-field

-----------------------------------------providerSelector-------------------------------------------
local function selectProviderWithFt()
    local ftMap = {
        vim = 'indent',
        python = {'indent'},
        git = ''
    }
    ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
            -- return a table with string elements: 1st is name of main provider, 2nd is fallback
            -- return a string type: use ufo inner providers
            -- return a string in a table: like a string type above
            -- return empty string '': disable any providers
            -- return `nil`: use default value {'lsp', 'indent'}
            -- return a function: it will be involved and expected return `UfoFoldingRange[]|Promise`

            -- if you prefer treesitter provider rather than lsp,
            -- return ftMap[filetype] or {'treesitter', 'indent'}
            return ftMap[filetype]
        end
    })
end

-- lsp->treesitter->indent
local function selectProviderWithChainByDefault()
    local ftMap = {
        vim = 'indent',
        python = {'indent'},
        git = ''
    }

    ---@param bufnr number
    ---@return Promise
    local function customizeSelector(bufnr)
        local function handleFallbackException(err, providerName)
            if type(err) == 'string' and err:match('UfoFallbackException') then
                return ufo.getFolds(bufnr, providerName)
            else
                return require('promise').reject(err)
            end
        end

        return ufo.getFolds(bufnr, 'lsp'):catch(function(err)
            return handleFallbackException(err, 'treesitter')
        end):catch(function(err)
            return handleFallbackException(err, 'indent')
        end)
    end

    ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
            return ftMap[filetype] or customizeSelector
        end
    })
end

local function selectProviderWithFunction()
    ---@param bufnr number
    ---@return UfoFoldingRange[]
    local function customizeSelector(bufnr)
        local res = {}
        table.insert(res, {startLine = 1, endLine = 3})
        table.insert(res, {startLine = 5, endLine = 10})
        return res
    end

    local ftMap = {
        vim = 'indent',
        python = {'indent'},
        git = customizeSelector
    }

    ufo.setup({
        provider_selector = function(bufnr, filetype, buftype)
            return ftMap[filetype]
        end
    })
end

-----------------------------------------providerSelector-------------------------------------------

------------------------------------------enhanceAction---------------------------------------------
local function peekOrHover()
    local winid = ufo.peekFoldedLinesUnderCursor()
    if winid then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local keys = {'a', 'i', 'o', 'A', 'I', 'O', 'gd', 'gr'}
        for _, k in ipairs(keys) do
            -- Add a prefix key to fire `trace` action,
            -- if Neovim is 0.8.0 before, remap yourself
            vim.keymap.set('n', k, '<CR>' .. k, {noremap = false, buffer = bufnr})
        end
    else
        -- coc.nvim
        vim.fn.CocActionAsync('definitionHover')
        -- nvimlsp
        vim.lsp.buf.hover()
    end
end

local function goPreviousClosedAndPeek()
    ufo.goPreviousClosedFold()
    ufo.peekFoldedLinesUnderCursor()
end

local function goNextClosedAndPeek()
    ufo.goNextClosedFold()
    ufo.peekFoldedLinesUnderCursor()
end

local function applyFoldsAndThenCloseAllFolds(providerName)
    require('async')(function()
        local bufnr = vim.api.nvim_get_current_buf()
        -- make sure buffer is attached
        ufo.attach(bufnr)
        -- getFolds return Promise if providerName == 'lsp'
        local ranges = await(ufo.getFolds(bufnr, providerName))
        local ok = ufo.applyFolds(bufnr, ranges)
        if ok then
            ufo.closeAllFolds()
        end
    end)
end

------------------------------------------enhanceAction---------------------------------------------

---------------------------------------setFoldVirtTextHandler---------------------------------------
local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ('  %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'MoreMsg'})
    return newVirtText
end

local function customizeFoldText()
    -- global handler
    ufo.setup({
        fold_virt_text_handler = handler
    })
end

local function customizeBufFoldText()
    -- buffer scope handler
    -- will override global handler if it is existed
    local bufnr = vim.api.nvim_get_current_buf()
    ufo.setFoldVirtTextHandler(bufnr, handler)
end

local function inspectVirtTextForFoldedLines()
    ufo.setup({
        enable_get_fold_virt_text = true,
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate, ctx)
            for i = lnum, endLnum do
                print('lnum: ', i, ', virtText: ', vim.inspect(ctx.get_fold_virt_text(i)))
            end
            return virtText
        end
    })
end

---------------------------------------setFoldVirtTextHandler---------------------------------------
