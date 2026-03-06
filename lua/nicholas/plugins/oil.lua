return {
    "stevearc/oil.nvim",
    opts = {
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
        },
    },
    keys = {
        { "<leader>e", "<cmd>Oil<CR>", desc = "Open file explorer" },
    },
}

