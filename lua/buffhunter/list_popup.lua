local Buffers = require("buffhunter.buffers") -- Import the Buffers module

ListPopup = {}

local config = nil -- This will hold the shared configuration
local list_buf, list_win = nil, nil -- Store the buffer and window handles
-- Setup function to receive the configuration
ListPopup.setup = function(shared_config)
    config = shared_config
end

ListPopup.open = function()
    -- Fetch the list of open buffers
    local buffers = Buffers.get_open_buffers()
    if not buffers or #buffers == 0 then
        buffers = { { bufnr = -1, name = "[No Buffers]" } }
    end

    -- Calculate dimensions
    local width = math.floor(vim.o.columns * 0.7)
    local height = math.floor(vim.o.lines * 0.4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create a buffer for the popup
    if not list_buf or not vim.api.nvim_buf_is_valid(list_buf) then
        list_buf = vim.api.nvim_create_buf(false, true)
    end

    -- Define options for the popup window
    local list_opts = {
        relative = "editor",
        title = "BuffHunter",
        title_pos = "center",
        width = width,
        height = height,
        row = row,
        col = col,
        border = config.border,
        style = "minimal",
        zindex = 30,
    }

    -- Open the popup window
    if not list_win or not vim.api.nvim_win_is_valid(list_win) then
        list_win = vim.api.nvim_open_win(list_buf, true, list_opts)
    end

    -- Configure the buffer
    vim.bo[list_buf].buftype = "nofile"
    vim.bo[list_buf].modifiable = true -- Allow modifications to the buffer content

    -- Populate the buffer with the initial list
    ListPopup.update(buffers, "")
end


ListPopup.update = function(buffers, query)
    if not list_buf or not vim.api.nvim_buf_is_valid(list_buf) then
        return
    end

    -- Filter buffers based on query
    local filtered_buffers = {}
    for _, buffer in ipairs(buffers) do
        -- Match using regex if query is not empty
        if query == "" or string.match(buffer.name:lower(), query:lower()) then
            table.insert(filtered_buffers, string.format("%d: %s", buffer.bufnr, buffer.name))
        end
    end

    -- Fallback if no buffers match
    if #filtered_buffers == 0 then
        filtered_buffers = { "[No Matching Buffers]" }
    end

    -- Defer updating the buffer
    vim.schedule(function()
        local modifiable = vim.bo[list_buf].modifiable
        vim.bo[list_buf].modifiable = true
        vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, filtered_buffers)
        vim.bo[list_buf].modifiable = modifiable
    end)
end


return ListPopup
