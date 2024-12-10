local Buffers = require("buffhunter.bufferslist")
local ListPopup = require("buffhunter.list_popup")

local SearchPopup = {}
local search_win = nil
local config = nil
local shared_state = nil

SearchPopup.setup = function(shared_config, state)
    config = shared_config
    shared_state = state
end

SearchPopup.open = function(list_win_pos)
    local search_height = 1
    local search_width = list_win_pos.width
    local search_row = list_win_pos.row + list_win_pos.height + 1
    local search_col = list_win_pos.col

    local search_buf = vim.api.nvim_create_buf(false, true)

    local search_opts = {
        relative = "editor",
        title = "Search",
        title_pos = "center",
        width = search_width,
        height = search_height,
        row = search_row,
        col = search_col,
        border = config.border,
        style = "minimal",
        zindex = 51,
    }

    if not search_win or not vim.api.nvim_win_is_valid(search_win) then
        search_win = vim.api.nvim_open_win(search_buf, true, search_opts)
    end

    -- Set up buffer options
    vim.bo[search_buf].buftype = "nofile"
    vim.api.nvim_buf_set_option(search_buf, 'modifiable', true)

    -- Set up keymaps
    local keymap_opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(search_buf, 'n', '<Down>', ':lua require("buffhunter.list_popup").move_selection(1)<CR>', keymap_opts)
    vim.api.nvim_buf_set_keymap(search_buf, 'n', '<Up>', ':lua require("buffhunter.list_popup").move_selection(-1)<CR>', keymap_opts)
    vim.api.nvim_buf_set_keymap(search_buf, 'i', '<Down>', '<Esc>:lua require("buffhunter.list_popup").move_selection(1)<CR>a', keymap_opts)
    vim.api.nvim_buf_set_keymap(search_buf, 'i', '<Up>', '<Esc>:lua require("buffhunter.list_popup").move_selection(-1)<CR>a', keymap_opts)
  vim.api.nvim_buf_set_keymap(search_buf, 'n', '<CR>', ':lua require("buffhunter.list_popup").select_buffer()<CR>', keymap_opts)
  vim.api.nvim_buf_set_keymap(search_buf, 'i', '<CR>', '<Esc>:lua require("buffhunter.list_popup").select_buffer()<CR>', keymap_opts)

    -- Set up autocommand for filtering
    vim.api.nvim_buf_attach(search_buf, false, {
        on_lines = function()
            local query = vim.trim(vim.api.nvim_buf_get_lines(search_buf, 0, -1, false)[1] or "")
            local buffers = Buffers.get_buffers()
            shared_state.query = query
            ListPopup.update(query)
        end,
    })

    -- Enter insert mode automatically
    vim.cmd('startinsert')

    return search_win
end

SearchPopup.close = function()
    if search_win and vim.api.nvim_win_is_valid(search_win) then
        vim.api.nvim_win_close(search_win, true)
    end
end

return SearchPopup
