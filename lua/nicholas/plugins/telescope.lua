return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
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
                preview = {
                    treesitter = false,
                    mime_hook = function(filepath, bufnr, opts)
                        local image_extensions = { "png", "jpg", "jpeg", "webp", "gif", "bmp" }
                        local ext = (string.match(filepath, "%.(%a+)$") or ""):lower()
                        local is_image = false
                        for _, v in ipairs(image_extensions) do
                            if v == ext then is_image = true; break end
                        end

                        if is_image then
                            local winid = opts.winid
                            local width = vim.api.nvim_win_get_width(winid)
                            local height = vim.api.nvim_win_get_height(winid)
                            local term = vim.api.nvim_open_term(bufnr, {})
                            local function send_output(_, data)
                                for _, d in ipairs(data) do
                                    vim.api.nvim_chan_send(term, d .. "\r\n")
                                end
                            end
                            vim.fn.jobstart({
                                "chafa",
                                "--format", "symbols",
                                "--symbols", "all",
                                "--color-extractor", "average",
                                "--color-space", "din99d",
                                "--dither", "bayer",
                                "--size", width .. "x" .. height,
                                filepath,
                            }, {
                                on_stdout = send_output,
                                stdout_buffered = true,
                            })
                        else
                            require("telescope.previewers.utils").set_preview_message(
                                bufnr, opts.winid, "Binary cannot be previewed"
                            )
                        end
                    end,
                },
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

