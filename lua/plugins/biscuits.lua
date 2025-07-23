return {
    "code-biscuits/nvim-biscuits",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
        require("nvim-biscuits").setup({
            -- This is a basic config.
            -- You can add any of the options from the README here.
            -- For example:
            default_config = {
                prefix_string = " 🔥 ",
            },
            language_config = {
                html = {
                    prefix_string = " 🌐 "
                },
                go = {
                    prefix_string = " 🐹 ",
                },
                javascript = {
                    prefix_string = " ✨ ",
                },
                typescript = {
                    prefix_string = " ✨ ",
                },
                python = {
                    prefix_string = " 🐍 ",
                }
            },
            cursor_line_only = true,
            toggle_keybind = "<leader>cb",
            show_on_start = true,
        })
    end,
}
