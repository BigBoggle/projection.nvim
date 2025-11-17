local config = require("projection.config")
local path = require("utils.path")
local project = require("utils.project")
local telescope = require("telescope.projects")
local M = {}

config.setup() -- apply default setup

function M.setup(opts)
    config.setup(opts)
end

function M.update_project_list()
    project.update_project_list()
end

function M.set_ignored(proj_path, ignored)
    project.set_ignored(proj_path, ignored)
end

-- Scan Dirs when entering Vim each time
-- Might make a way to check if changes have been made to save on start time
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.defer_fn(M.update_project_list, 1000) -- Change this to update_list later
    end,
    once = true,
})

-- Default Keymaps
-- Look into how to make them more user-customizable
vim.keymap.set("n", "<leader>fp", function()
    telescope.browse_projects()
end, { desc = "Find Project" })

vim.api.nvim_create_user_command("BrowseProjects", function()
    telescope.browse_projects()
end, { nargs = 0 })

vim.api.nvim_create_user_command("ScanProjects", function()
    M.update_project_list()
end, { nargs = 0 })

vim.api.nvim_create_user_command("IgnoreProject", function(opts)
    M.set_ignored(opts.args, true)
end, { nargs = 1 })

vim.api.nvim_create_user_command("UnignoreProject", function(opts)
    M.set_ignored(opts.args, false)
end, { nargs = 1 })

return M
