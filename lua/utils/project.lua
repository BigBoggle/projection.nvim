-- Deals with project listing and navigation
local config = require("projection.config")
local path = require("utils.path")
local stdpath = config.options.datapath or vim.fn.stdpath("data") .. "/"
local ignore_file = stdpath .. "projection/ignore.txt"

local M = {}

-- Scan directories based on user/default options, then write to projects.txt
-- TODO: Implement file globbing
M.update_project_list = function()
    local opts = config.options
    local excluded = vim.deepcopy(opts.exclude_paths)
    -- Probably should just overwrite the file each run, unless no changes made

    -- If ignored or excluded found within projects.txt, delete it

    -- Copy ignore list elements to excluded table
    local f = io.open(ignore_file, "r")
    if f then
        for line in f:lines() do
            line = vim.trim(line)
            if line ~= "" then
                table.insert(excluded, line)
            end
        end
        f:close()
    end

    -- Open current projects file and get the elements into table,
    -- then remove those elements if they match the ones in excluded
    -- Write to projects file
    local dirs = path.find_dirs(opts.paths, opts.filters, excluded)

    path.write_dirs(dirs, "")
    -- Prob should add sorting alphabetically here
end

-- Delete a project from the list
-- This just appends the path to the ignore list, updating the projects list should happen at each plugin run
---@param project string
---@param ignore boolean
M.set_ignored = function(project, ignore)
    project = vim.fn.fnamemodify(vim.trim(project), ":p")
    if project == "" then
        return
    end

    local ignore_list = {}
    local exists = {} -- list of files that exist within the ignore list

    -- Put existing ignore list into a table
    local f = io.open(ignore_file, "r")
    if f then
        for line in f:lines() do
            line = vim.fn.fnamemodify(vim.trim(line), ":p")
            if line ~= "" then
                ignore_list[#ignore_list + 1] = line
                exists[line] = true
            end
        end
        f:close()
    end

    if ignore then
        -- Check for duplicate, otherwise insert into ignore list
        if exists[project] then
            vim.notify("Project Already in Ignore list:" .. project, vim.log.levels.WARN)
            return
        end
        table.insert(ignore_list, project)
        vim.notify("Project added to ignore list: " .. project, vim.log.levels.INFO)
    else
        -- Remove the the project from the ignore list
        if exists[project] then
            -- Remove from the table
            local i = 1
            while i <= #ignore_list do
                if ignore_list[i] == project then
                    table.remove(ignore_list, i)
                else
                    i = i + 1
                end
            end
        end
        vim.notify("Project removed from ignore list: " .. project, vim.log.levels.INFO)
    end

    -- Sort
    table.sort(ignore_list, function(a, b)
        return a:lower() < b:lower()
    end)

    -- Write ignored to ignore.txt
    local f_write, err = io.open(ignore_file, "w") -- 90's dads will get this epic variable naming
    if not f_write then
        vim.notify("Failed to open ignore list: " .. err, vim.log.levels.ERROR)
        return
    end
    for _, paths in ipairs(ignore_list) do
        f_write:write(paths .. "\n")
    end
    f_write:close()

    print("File written successfully")
end

return M
