local config = require("projection.config")
-- Path finding and storing functions
local uv = vim.uv
local M = {}
local is_windows = vim.fn.has("win32") or vim.fn.has("wsl")
local stdpath = config.options.datapath or vim.fn.stdpath("data")

-- [[

-- TODO:
--  Save project file paths to a good location to read/write from/to
--  Allow for the user to select whether they will manually add projects or let auto_scanning work
--  This can be expanded upon by writing to a list of excluded projects individually through the telescope menu
--  Integrate with Telescope to pick projects

-- BUG:
-- When changing directories with tabs, the plugin hijacks all tabs and changes their directory.
-- The fix is more than likely just changing directory for the current buffer only

--]]

-- Check if data dir exists, creates it if it doesn't
M.ensure_data_dir = function()
    local directory = stdpath .. "projection"
    local stat = uv.fs_stat(directory)
    if stat and stat.type == "directory" then
        return directory
    else
        vim.fn.mkdir(directory, "p")
        print("Data dir not found, creating...")
    end
    return directory
end

-- Normalize path and handle windows filesystem
---@param path string
---@return string
M.normalize_path = function(path)
    local normalized = path:gsub("\\", "/"):gsub("//", "/")
    if is_windows then
        normalized = normalized:sub(1, 1):lower() .. normalized:sub(2)
    end
    return normalized
end

-- Return a table of strings of paths to valid directories based on user specified criteria Ex: .git folders, formatter files etc
---@param paths string[]
---@param filter string[]
---@param exclude string[]
---@return string[]
M.find_dirs = function(paths, filter, exclude)
    local dirs = {}
    local seen = {} -- Look for duplicate entries for directories with multiple filtered file matches

    -- Might want to add exclude_filters to opts so you can also not add certain folders to project dirs
    -- Might simplify this into the match function later
    local function is_excluded(pattern, excluded)
        for _, e in ipairs(excluded) do
            if pattern == e then
                return true
            end
        end
        return false
    end

    local function target_match(pattern)
        if is_excluded(pattern, exclude) then
            return false
        end
        for _, t in ipairs(filter) do
            -- Add exclusion here
            if pattern == t then
                return true
            end
        end
        return false
    end

    local function scan(dir)
        -- Pattern exclusion
        for _, ex in ipairs(exclude) do
            if dir:find(vim.fn.expand(ex), 1, true) == 1 then
                -- print("Skipping excluded subtree:", dir)
                return
            end
            --[[            if vim.fn.expand(dir) == vim.fn.expand(ex) then
                print("Skipping excluded path:", dir)
                return
            end ]]
        end

        local fd = uv.fs_scandir(dir)
        if not fd then
            return
        end

        while true do
            local name, type = uv.fs_scandir_next(fd)
            if not name then
                break
            end
            local full_path = M.normalize_path(dir .. "/" .. name)

            if target_match(name) then
                -- Check for dups
                local normalized = M.normalize_path(dir)
                if not seen[normalized] then
                    seen[normalized] = true
                    table.insert(dirs, normalized)
                end
            end

            if type == "directory" then
                scan(full_path) -- go into subdir
            end
        end
    end

    for _, path in ipairs(paths) do
        local expanded = vim.fn.expand(path)
        local stat = uv.fs_stat(expanded)
        if not stat or stat.type ~= "directory" then
            vim.notify("Invalid path: " .. path, vim.log.levels.WARN)
        else
            scan(expanded)
        end
    end

    return dirs
end

--- Write table of directory paths (input) to file (output)
---@param dirs string[]
---@param output string
---@return nil
M.write_dirs = function(dirs, output)
    local data_dir = M.ensure_data_dir()
    local file_path = output and output ~= "" and output or (data_dir .. "/projects.txt") -- Check to see if different output path is specified, otherwise use default

    -- Default path will be to write to plugin folder
    local f, err = io.open(file_path, "w") -- Open file for writing
    if not f then
        vim.notify("Failed to open for writing: " .. err, vim.log.levels.ERROR)
        return
    end

    for _, dir in ipairs(dirs) do
        f:write(dir .. "\n")
    end
    f:close()
    -- vim.notify("Wrote project paths to: " .. file_path, vim.log.levels.INFO)
    -- vim.notify("Wrote project paths to: " .. file_path, vim.log.levels.DEBUG)
end

-- Returns a list of project directories
---@param file string
---@return string[]:
M.read_dirs = function(file)
    local project_dirs = {}
    local f = io.open(file, "r")
    if not f then
        vim.notify("Failed to open file: " .. file, vim.log.levels.ERROR)
        return {}
    end
    for line in f:lines() do
        table.insert(project_dirs, vim.fn.expand(line))
    end
    f:close()
    return project_dirs
end

return M
