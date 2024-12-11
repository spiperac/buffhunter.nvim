local BufferList = require("buffhunter.bufferlist")
local Formatter = require("buffhunter.formatter")

local ListPopup = {}
local config = nil
local shared_state = nil
local list_buf, list_win = nil, nil

local function get_buffer_indicator(line)
    if line == shared_state.selected then
        return ">"
    else
        return " "
    end
end

ListPopup.setup = function(shared_config, state)
    config = shared_config
    shared_state = state
    -- Initialize the selection index
    shared_state.selected = 1
end

ListPopup.open = function()
    local buffers = BufferList.get_buffers()
    if not buffers or #buffers == 0 then
        buffers = { { bufnr = -1, name = "[No Buffers]" } }
    end

    local width = math.floor(vim.o.columns * 0.7)
    local height = math.floor(vim.o.lines * 0.4)
    local row = math.floor((vim.o.lines - height) / 2) - 1
    local col = math.floor((vim.o.columns - width) / 2)

    if not list_buf or not vim.api.nvim_buf_is_valid(list_buf) then
        list_buf = vim.api.nvim_create_buf(false, true)
    end

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

    if not list_win or not vim.api.nvim_win_is_valid(list_win) then
        list_win = vim.api.nvim_open_win(list_buf, true, list_opts)
        shared_state.list_win = list_win
    end

    vim.bo[list_buf].buftype = "nofile"
    vim.bo[list_buf].modifiable = false
    vim.wo[list_win].winhl = 'Normal:Normal'
    vim.wo[list_win].winblend = 0
    vim.wo[list_win].wrap = false
    vim.wo[list_win].cursorline = false

    -- Initialize the filtered buffers
    shared_state.filtered_buffers = buffers

    -- Update buffer list
    ListPopup.update("")

    return { row = row, col = col, height = height, width = width }
end

ListPopup.update = function(query)
    local buffers = BufferList.get_buffers({ with_icons = config.icons })
    local filtered_lines = {}
    shared_state.filtered_buffers = {}  -- Reset filtered buffers
    local highlights = {}

    for i, buffer in ipairs(buffers) do 
        if query == "" or string.match(buffer.name:lower(), query:lower()) then
            buffer.indicator = get_buffer_indicator(i)
            table.insert(shared_state.filtered_buffers, buffer)  -- Store complete buffer objects
            table.insert(filtered_lines, Formatter.format_buffer_line(buffer, config))  -- Store formatted lines
        end
    end
    
    for i, buffer in ipairs(shared_state.filtered_buffers) do
            -- Store highlight positions
            table.insert(highlights, {
                line = i - 1,
                number = { start_col = 0, end_col = 2, hl = "Number" },
                icon = { start_col = 5, end_col = 5 + #buffer.icon, hl = buffer.icon_hl },
                path = { start_col = 5 + #buffer.icon + 1, end_col = 5 + #buffer.icon + #buffer.name + 1, hl = "Comment" },
            })
    end

    if #filtered_lines == 0 then
        filtered_lines = { "[No Matching Buffers]" }
    end

    -- Ensure selection stays within bounds
    shared_state.selected = math.min(shared_state.selected, #filtered_lines)
    if shared_state.selected < 1 then
        shared_state.selected = 1
    end

    -- Make highlights namespace
    local ns = vim.api.nvim_create_namespace('buffhunter')

    -- Update the buffer content
    vim.schedule(function()
        vim.bo[list_buf].modifiable = true
        vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, filtered_lines)
        vim.bo[list_buf].modifiable = false

        -- Clear existing highlights
        vim.api.nvim_buf_clear_namespace(list_buf, -1, 0, -1)

        -- Add highlight for selected line
        if #filtered_lines > 0 and filtered_lines[1] ~= "[No Matching Buffers]" then
            -- Apply hightlights 
            Formatter.make_highlights(list_buf, highlights, ns)
            vim.api.nvim_buf_add_highlight(list_buf, -1, "Visual", shared_state.selected - 1, 0, -1)
        end
        highlights = {}
    end)
end

ListPopup.move_selection = function(offset)
    if #shared_state.filtered_buffers == 0 then
        return
    end

    -- Update selection with bounds checking
    shared_state.selected = math.max(1, math.min(
        shared_state.selected + offset,
        #shared_state.filtered_buffers
    ))

    -- Refresh the display
    ListPopup.update(shared_state.query)
end

ListPopup.close = function()
    if list_win and vim.api.nvim_win_is_valid(list_win) then
        vim.api.nvim_win_close(list_win, true)
    end
end

ListPopup.select_buffer = function()
    local selected_buffer = shared_state.filtered_buffers[shared_state.selected]
    if selected_buffer and selected_buffer.bufnr then
        -- Close popups first
        require('buffhunter').close()
        -- Switch to the selected buffer
        vim.api.nvim_set_current_buf(selected_buffer.bufnr)
    end
end

return ListPopup
