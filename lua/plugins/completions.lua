return {
    'github/copilot.vim',
    vim = {
        'on_attach',
        function()
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")',
                { noremap = true, silent = true, expr = true })
            vim.api.nvim_set_keymap('i', '<C-K>', 'copilot#Dismiss()', { noremap = true, silent = true, expr = true })
            vim.api.nvim_set_keymap('n', '<leader>cp', ':Copilot panel<CR>', { noremap = true, silent = true })
        end,
    }
}
