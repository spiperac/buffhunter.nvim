local search_popup = require("buffhunter.search_popup")
local list_popup = require("buffhunter.list_popup")
local buffers = require("buffhunter.buffers")

local M = {}
local config = {
    width = 0.7,        -- 70% of screen width
    height = 0.4,       -- 40% of screen height
    border = "double",  -- Border style
    icons = true,       -- Enable file icons
    git_signs = true,   -- Enable git signs
    keymaps = {
        close = "<ESC>",
        move_up = "k",
        move_down = "j",
        select = "<CR>",
        delete = "x",
        hsplit = "s",
        vsplit = "v"
    }
}

-- Your configuration defaults
M.config = config
-- Shared state for popups
local shared_state = {
    buffers = {}, -- Store the list of buffers
    query = "",   -- Store the current search query
}

-- Setup function that will be called by lazy.nvim
function M.setup(opts)
    -- Merge user config with defaults
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
    -- Pass the configuration to the search_popup module
    shared_state.buffers = buffers.get_open_buffers()
    search_popup.setup(M.config, shared_state)
    list_popup.setup(M.config)

    -- Load the popup module
    require('buffhunter')
    
    -- Set commands
    vim.api.nvim_create_user_command('BuffHunter', function()
        require('buffhunter').toggle()
    end, {})
end


M.toggle = function()
  list_popup.open()
  search_popup.open()
end

return M
