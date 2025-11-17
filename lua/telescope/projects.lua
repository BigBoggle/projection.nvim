local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local devicons = require("nvim-web-devicons")

-- All telescope pickers are defined here

--[[
-- TODO: Set keybinds for different actions
--]]

local conf = require("telescope.config").values

local M = {}

-- Pass in opts and data as a table of strings to project picker
---@param opts any
---@param data string[]:
M.project_picker = function(opts, data)
    opts = opts or {}
    --local entries = {}

    --[[ Webdev Icon Testing, currently displays an icon, but messes with file pathing

    -- TODO: Assign webdev icon based on the majority of what type of file exists within the project, or allow a manual assignment
    -- We can check by how the content was filtered maybe to assign this, but this would require a heavy rewrite

    for _, path in ipairs(data) do
        local name = vim.fn.fnamemodify(path, ":t")
        local ext = vim.fn.fnamemodify(path, ":e")
        local icon, _ = devicons.get_icon(name, ext, { default = true })
        table.insert(entries, string.format("%s %s", icon, path))
    end ]]

    pickers
        .new(opts, {
            prompt_title = "Projects",
            finder = finders.new_table({
                results = data,
            }),
            sorter = conf.generic_sorter(opts),
        })
        :find()
end

M.browse_projects = function(opts)
    opts = opts or {}
    local file_path = vim.fn.stdpath("data") .. "/projection/projects.txt"
    local ignore_path = vim.fn.stdpath("data") .. "/projection/ignore.txt"

    local projects = {}
    local ignored = {}

    local f = io.open(file_path, "r")
    if f then
        for line in f:lines() do
            local proj_path = vim.fn.fnamemodify(vim.trim(line), ":p") -- normalize
            table.insert(projects, proj_path)
        end
        f:close()
    else
        vim.notify("No project paths file exists!", vim.log.levels.ERROR)
        return
    end

    local f_ignore = io.open(ignore_path, "r")
    if f_ignore then
        for line in f_ignore:lines() do
            local path = vim.fn.fnamemodify(vim.trim(line), ":p")
            ignored[path] = true
        end
        f_ignore:close()
    end

    -- Filter out ignored projects
    local filtered_projects = {}
    for _, proj in ipairs(projects) do
        if not ignored[proj] then
            table.insert(filtered_projects, proj)
        end
    end

    M.project_picker(opts, filtered_projects)
end

M.browse_pinned = function(opts)
    opts = opts or {}
    local file_path = vim.fn.stdpath("data") .. "projection/pinned.txt"
    local lines = {}
    local f = io.open(file_path, "r")
    if not f then
        vim.notify("No pinned paths file exists!", vim.log.levels.ERROR)
        return
    end

    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()

    M.project_picker(opts, lines)
end

return M
