return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")
        local map = vim.keymap.set

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })

        telescope.load_extension("fzf")

        map("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
        map("n", "<leader>fg", builtin.live_grep,   { desc = "Live grep" })
        map("n", "<leader>fb", builtin.buffers,     { desc = "Find buffers" })
        map("n", "<leader>fs", builtin.grep_string, { desc = "Grep string under cursor" })
        map("n", "<leader>fh", builtin.help_tags,   { desc = "Help tags" })
    end,
}

