---@class ProjectionConfig
local M = {}

---@type ProjectionOptions
---@diagnostic disable-next-line: missing-fields
M.options = {}

---@class ProjectionOptions
local defaults = {
    -- projection looks here for paths by default, might add it via lsp later
    paths = { "" },
    -- NOTE: I forsee that maybe nested git repos might lead to project duplication

    -- Don't look here for projects
    exclude_paths = { "" },

    -- Filter project files to search for
    -- TODO: Add pattern globbing later
    filters = { ".git" }, -- Don't want to force defaults on anyone

    -- User option to allow for manual project tracking
    -- auto_scan_paths = true, -- Legacy, unimplemented

    -- Plugin files are stored in vim.fn.stdpath("data")
    -- You can change it here if you have something better in mind...
    -- TEST: Test this later
    datapath = vim.fn.stdpath("data"),
}

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", defaults, options or {})
    -- Rest of setup goes here
end

return M
