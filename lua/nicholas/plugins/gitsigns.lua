return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add          = { text = "│" },
            change       = { text = "│" },
            delete       = { text = "󰍵" },
            topdelete    = { text = "‾" },
            changedelete = { text = "~" },
            untracked    = { text = "│" },
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local map = vim.keymap.set

            map("n", "]h", gs.next_hunk,                    { buffer = bufnr, desc = "Next hunk" })
            map("n", "[h", gs.prev_hunk,                    { buffer = bufnr, desc = "Prev hunk" })
            map("n", "<leader>hs", gs.stage_hunk,           { buffer = bufnr, desc = "Stage hunk" })
            map("n", "<leader>hr", gs.reset_hunk,           { buffer = bufnr, desc = "Reset hunk" })
            map("n", "<leader>hb", gs.blame_line,           { buffer = bufnr, desc = "Blame line" })
            map("n", "<leader>tb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle blame" })
        end,
    },
}

