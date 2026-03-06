return {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
        bind = true,
        handler_opts = {
            border = "rounded",
        },
        hint_enable = false,        -- disable inline virtual text hint, popup is enough
        hi_parameter = "LspSignatureActiveParameter", -- highlight active parameter
        always_trigger = true,      -- show signature as soon as you type (
        auto_close_after = nil,     -- keep open until you close )
        toggle_key = "<C-s>",       -- manually toggle signature with Ctrl+S
    },
}

