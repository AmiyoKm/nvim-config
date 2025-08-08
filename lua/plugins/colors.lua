return {
    {
        "folke/tokyonight.nvim",
        -- Add these options
        opts = {
            transparent = true, -- Enable this to make the background transparent
            terminal_colors = false,
        },
        -- Your config function is fine
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme "tokyonight-moon"
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            theme = "tokyonight",
        }
    },
}
