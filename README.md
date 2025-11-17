# projection.nvim 

 **projection.nvim** is my first attempt at making a neovim plugin after trying multiple project management plugins and not caring for how they worked.

## Requirements
 Neovim >= 0.11.0

## Features

- Project pattern finding for easy access.
- Telescope integration 

### Planned Features
- Project tracking and removal via the telescope picker
- Potential support for fzf based pickers 
    - Currently, only telescope.nvim is supported

## Installation

Install via your favorite package manager: 

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

Ex:
```lua
return {
    "BigBoggle/projection.nvim",
    config = function()
    require("projection").setup({
        -- projection looks here for paths by default, might add it via lsp later
        paths = { "" },

        -- Ignore these specified project directories, though you can use ':IgnoreProjects' as well
        exclude_paths = { "" },

        -- Filter project files to search for
        filters = { ".git" },


        -- Change the default path for where project lists are stored.
        datapath = vim.fn.stdpath("data"),
    })
    end,
}
```


