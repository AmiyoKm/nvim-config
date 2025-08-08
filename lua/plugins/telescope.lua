return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        -- Add telescope setup and options here
        require('telescope').setup {
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    ".git",
                },
            },
        }

        local builtin = require('telescope.builtin')
        -- Find Files
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
        -- Find Word (Live Grep)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
        -- Recently Opened Files
        vim.keymap.set('n', '<leader>fh', builtin.oldfiles, { desc = '[F]ind [H]istory' })
        -- Find Buffers
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
        -- Jump to Marks (Bookmarks)
        vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = '[F]ind [M]arks' })
        -- Help Tags (remapped from fh)
        vim.keymap.set('n', '<leader>ft', builtin.help_tags, { desc = '[F]ind Help [T]ags' })
        
    end
}
