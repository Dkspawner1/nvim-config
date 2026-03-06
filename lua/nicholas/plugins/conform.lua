return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            odin = { "odinfmt" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            rust = { "rustfmt" },
        },
    },
}

