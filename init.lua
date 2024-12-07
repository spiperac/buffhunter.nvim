local M = {}

-- Your configuration defaults
M.config = {
    width = 0.7,        -- 70% of screen width
    height = 0.4,       -- 40% of screen height
    border = "double",  -- Border style
    icons = true,       -- Enable file icons
    git_signs = true,   -- Enable git signs
    keymaps = {
        close = "q",
        move_up = "k",
        move_down = "j",
        select = "<CR>",
        delete = "x",
        hsplit = "s",
        vsplit = "v"
    }
}

-- Setup function that will be called by lazy.nvim
function M.setup(opts)
    -- Merge user config with defaults
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    
    -- Load the popup module
    require('buffhunter.popup')
    
    -- Set commands
    vim.api.nvim_create_user_command('BuffHunter', function()
        require('buffhunter.popup').toggle()
    end, {})
end

return M
