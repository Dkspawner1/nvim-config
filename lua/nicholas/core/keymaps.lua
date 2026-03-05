vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Better escape
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move left" })
map("n", "<C-l>", "<C-w>l", { desc = "Move right" })
map("n", "<C-j>", "<C-w>j", { desc = "Move down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move up" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Diagnostics
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show error" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Helper: close all terminal windows and kill their buffers
local function close_terminal()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

-- Helper: read collections from ols.json and build -collection flags
local function get_odin_collection_flags(project_root)
    local ols_path = project_root .. "/ols.json"
    local f = io.open(ols_path, "r")
    if not f then return "" end
    local content = f:read("*a")
    f:close()

    local flags = ""
    for name, path in content:gmatch('"name"%s*:%s*"([^"]+)".-"path"%s*:%s*"([^"]+)"') do
        flags = flags .. " -collection:" .. name .. "=" .. project_root .. "/" .. path
    end
    return flags
end

-- Helper: find project root by walking up from current dir
local function find_project_root(start_dir)
    local root = start_dir
    while root ~= "/" do
        if vim.fn.filereadable(root .. "/ols.json") == 1 then
            return root
        end
        if vim.fn.isdirectory(root .. "/src") == 1 then
            return root
        end
        root = vim.fn.fnamemodify(root, ":h")
    end
    return start_dir
end

-- Helper: auto-generate ols.json if missing
local function ensure_ols_json(project_root)
    local ols_path = project_root .. "/ols.json"
    if vim.fn.filereadable(ols_path) == 1 then return end
    if vim.fn.isdirectory(project_root .. "/src") == 0 then return end

    local project_name = vim.fn.fnamemodify(project_root, ":t")
    local content = string.format([[{
    "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/ols.schema.json",
    "collections": [
        {
            "name": "%s",
            "path": "src"
        }
    ],
    "enable_semantic_tokens": true,
    "enable_hover": true,
    "enable_snippets": true,
    "enable_document_symbols": true,
    "enable_inlay_hints": true
}]], project_name)

    local f = io.open(ols_path, "w")
    if f then
        f:write(content)
        f:close()
        vim.notify("Generated ols.json for project: " .. project_name, vim.log.levels.INFO)
    end
end

-- Auto-generate ols.json when opening or entering an Odin file
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    pattern = "*.odin",
    callback = function()
        local dir = vim.fn.expand("%:p:h")
        local root = find_project_root(dir)
        ensure_ols_json(root)
    end,
})

-- Manually force generate ols.json for current project
map("n", "<leader>oi", function()
    local dir = vim.fn.expand("%:p:h")
    local root = find_project_root(dir)
    os.remove(root .. "/ols.json")
    ensure_ols_json(root)
end, { desc = "Init ols.json for project" })

-- Build & run: Ctrl+D to compile and show output in bottom split
map("n", "<C-d>", function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local ext = vim.fn.expand("%:e")

    close_terminal()

    local cmd
    if ext == "odin" then
        local project_root = find_project_root(dir)
        ensure_ols_json(project_root)
        local collections = get_odin_collection_flags(project_root)
        cmd = "odin run " .. dir .. collections
    elseif ext == "c" then
        cmd = "gcc " .. file .. " -o /tmp/out && /tmp/out"
    elseif ext == "cpp" then
        cmd = "g++ " .. file .. " -o /tmp/out && /tmp/out"
    elseif ext == "rs" then
        cmd = "cargo run"
    else
        print("No build command for filetype: " .. ext)
        return
    end

    vim.cmd("w")
    vim.cmd("botright split | resize 15 | terminal " .. cmd)
end, { desc = "Build and run" })

-- Ctrl+T: open terminal in file's directory, or focus existing one
map("n", "<C-t>", function()
    local dir = vim.fn.expand("%:p:h")

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_set_current_win(win)
            vim.cmd("startinsert")
            return
        end
    end

    vim.cmd("botright split | resize 15 | terminal")
    vim.defer_fn(function()
        vim.fn.chansend(vim.b.terminal_job_id, "cd " .. dir .. "\n")
        vim.cmd("startinsert")
    end, 100)
end, { desc = "Open terminal" })

-- Ctrl+X in terminal: fully kill it and return to code
map("t", "<C-x>", function()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
end, { desc = "Kill terminal" })

-- Auto-enter insert mode when focusing a terminal window
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
    end,
})

