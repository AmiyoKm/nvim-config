-- neovim/nvim-lspconfig
-- This table represents the configuration for the nvim-lspconfig plugin
-- and its dependencies, managed by a plugin manager like 'lazy.nvim'.
return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        -- Snippets
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
    },
    config = function()
        -- Add cmp_nvim_lsp capabilities to the default lspconfig setup.
        -- This must be done before any servers are configured.
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- Define which filetypes should be auto-formatted on save.
        local autoformat_filetypes = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "python",
            "go",
            "lua",
        }

        -- Centralized LspAttach autocommand.
        -- This function runs once for each language server that attaches to a buffer.
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local bufnr = event.buf
                local opts = { buffer = bufnr }

                -- Setup auto-formatting on save for supported filetypes and clients.
                -- We check if the client has the 'formatting' capability.
                if client and client.supports_method('textDocument/formatting') then
                    if vim.tbl_contains(autoformat_filetypes, vim.bo[bufnr].filetype) then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            group = vim.api.nvim_create_augroup('LspFormatOnSave', {}),
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr, async = true })
                            end,
                        })
                    end
                end

                -- Keymaps for LSP features. These are only set for buffers with an active LSP.
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' ,'i'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end,
        })

        -- Add borders to floating windows for LSP UI elements.
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,
            { border = 'rounded' })

        -- Configure diagnostic icons and settings.
        vim.diagnostic.config({
            update_in_insert = true,
            virtual_text = true,
            severity_sort = true,
            float = {
                style = 'minimal',
                border = 'rounded',
                header = '',
                prefix = '',
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN] = '▲',
                    [vim.diagnostic.severity.HINT] = '⚑',
                    [vim.diagnostic.severity.INFO] = '»',
                },
            },
        })

        -- Setup Mason to manage LSP servers, linters, and formatters.
        require('mason').setup({})
        require('mason-lspconfig').setup({
            -- A list of servers to automatically install if they're not already installed.
            ensure_installed = {
                "lua_ls",
                "intelephense",
                "ts_ls",
                "eslint",
                "gopls",
                "pyright"
            },
            -- Handlers to configure each language server.
            handlers = {
                -- Default handler for any server not explicitly defined below.
                function(server_name)
                    require('lspconfig')[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                -- Custom handler for lua_ls.
                lua_ls = function()
                    require('lspconfig').lua_ls.setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = 'LuaJIT' },
                                diagnostics = { globals = { 'vim' } },
                                workspace = { library = { vim.env.VIMRUNTIME } },
                                telemetry = { enable = false },
                            },
                        },
                    })
                end,

                -- Custom handler for gopls.
                gopls = function()
                    require('lspconfig').gopls.setup({
                        capabilities = capabilities,
                        settings = {
                            gopls = {
                                analyses = {
                                    unusedparams = true,
                                    shadow = true,
                                    staticcheck = true,
                                },
                            },
                        },
                    })
                end,

                -- Handler for our Go linter server.
                -- golangci_lint_ls = function()
                --    require('lspconfig').golangci_lint_ls.setup({
                --       capabilities = capabilities,
                --      filetypes = { 'go', 'gomod' },
                --  })
                -- end,

                -- Handler for Python LSP.
                pyright = function()
                    require('lspconfig').pyright.setup({
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    diagnosticMode = "openFilesOnly",
                                    useLibraryCodeForTypes = true
                                }
                            }
                        }
                    })
                end,
            },
        })

        -- Setup nvim-cmp for autocompletion.
        local cmp = require('cmp')
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip', keyword_length = 2 },
                { name = 'buffer',  keyword_length = 3 },
                { name = 'path' },
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local kind_icons = {
                        Text = "",
                        Method = "m",
                        Function = "ƒ",
                        Constructor = "",
                        Field = "",
                        Variable = "󰀫",
                        Class = "",
                        Interface = "",
                        Module = "",
                        Property = "",
                        Unit = "",
                        Value = "�",
                        Enum = "",
                        Keyword = "󰌋",
                        Snippet = "",
                        Color = "󰏘",
                        File = "󰈙",
                        Reference = "",
                        Folder = "󰉋",
                        EnumMember = "",
                        Constant = "󰏿",
                        Struct = "",
                        Event = "",
                        Operator = "󰆕",
                        TypeParameter = "󰊄",
                    }
                    item.kind = string.format('%s %s', kind_icons[item.kind] or '?', item.kind)
                    item.menu = ({
                        nvim_lsp = '[LSP]',
                        luasnip = '[Snippet]',
                        buffer = '[Buffer]',
                        path = '[Path]',
                    })[entry.source.name]
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-f>'] = cmp.mapping.scroll_docs(5),
                ['<C-u>'] = cmp.mapping.scroll_docs(-5),
                ['<C-e>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = 'select' })
                    elseif require('luasnip').expand_or_jumpable() then
                        require('luasnip').expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = 'select' })
                    elseif require('luasnip').jumpable(-1) then
                        require('luasnip').jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
        })
    end
}
