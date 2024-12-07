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
    require('buffhunter')
    
    -- Set commands
    vim.api.nvim_create_user_command('BuffHunter', function()
        require('buffhunter').toggle()
    end, {})
end

-- Global variables
local selected_line = 1
local buffers = {}
local popup_win = nil
local popup_buf = nil
local original_win = nil

local function get_file_icon(filename)
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if has_devicons then
        local extension = filename:match("^.+%.(.+)$") or ""
        local icon, icon_hl = devicons.get_icon(filename, extension, { default = true })
        return icon or "", icon_hl or ""
    end
    return "", ""
end

local function get_git_status(bufnr)
    local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
    if not has_gitsigns then
        return "", ""
    end

    -- Get buffer status from gitsigns
    local status = vim.b[bufnr].gitsigns_status_dict
    if not status then
        return "", ""
    end

    local symbol = "●"
    
    -- Check if file has been modified since last commit
    if status.changed and status.changed > 0 then
        return symbol, "GitChanges"      
    end
    
    -- Check if file has staged changes
    if status.staged and status.staged > 0 then
        return symbol, "GitStaged"     
    end
    
    -- Check if file is tracked but clean
    if status.head then  -- If head exists, file is tracked
        return symbol, "GitClean"
    end

    -- Untracked files
    return symbol, "NonText"
end

-- Add this function to create the custom highlight groups
local function setup_highlights()
    vim.api.nvim_set_hl(0, "GitChanges", { fg = "#E5C07B" })  -- Yellow for modified
    vim.api.nvim_set_hl(0, "GitStaged", { fg = "#98C379" })   -- Green for staged
    vim.api.nvim_set_hl(0, "GitClean", { fg = "#445254" })    -- Gray-ish for clean/committed
end


local function get_buffer_indicator(line)
    if line == selected_line then
        return ">"
    else
        return " "
    end
end

M.open = function()
    original_win = vim.api.nvim_get_current_win()
    buffers = vim.fn.getbufinfo({ buflisted = 1 })

    -- Set selected line to the currently active buffer
    for i, buf in ipairs(buffers) do
        if buf.bufnr == vim.api.nvim_get_current_buf() then
            selected_line = i
            break
        end
    end
    
    setup_highlights()
    local width = math.floor(vim.o.columns * 0.7)
    local height = math.floor(vim.o.lines * 0.4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    popup_buf = vim.api.nvim_create_buf(false, true)
    
    local opts = {
        relative = "editor",
        title = "BuffHunter",
        title_pos = "center",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "double",
        style = "minimal",
        zindex = 50,
    }
 
    popup_win = vim.api.nvim_open_win(popup_buf, true, opts)
    
    -- Set window options
    vim.wo[popup_win].winhl = 'Normal:Normal'
    vim.wo[popup_win].winblend = 0
    vim.wo[popup_win].wrap = false
    vim.wo[popup_win].cursorline = false
    vim.wo[popup_win].cursorcolumn = false

    -- Create lines and collect highlight information
    local lines = {}
    local highlights = {}
    
    for i, buf in ipairs(buffers) do
        local indicator = get_buffer_indicator(i)
        local icon, icon_hl = get_file_icon(buf.name)
        local git_status, git_hl = get_git_status(buf.bufnr)
        local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":~:.") or "[No Name]"
        local padding = width - #name - #icon - #git_status - 8
        if padding < 0 then padding = 0 end
        
        local line = string.format("%s %2d %s %s%s%s",
            indicator,
            buf.bufnr,
            icon,
            name,
            string.rep(" ", padding),
            git_status
        )
        
        table.insert(lines, line)
        
        -- Store highlight positions
        table.insert(highlights, {
            line = i - 1,
            number = { start_col = 0, end_col = 2, hl = "Number" },
            icon = { start_col = 5, end_col = 5 + #icon, hl = icon_hl },
            path = { start_col = 5 + #icon + 1, end_col = 5 + #icon + #name + 1, hl = "Number" },
            git = { 
                start_col = #line - #git_status, 
                end_col = #line, 
                hl = git_hl 
            }
        })
    end

    -- Set content
    vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, #lines > 0 and lines or { "No buffers available" })

    -- Apply highlights using extmarks
    local ns = vim.api.nvim_create_namespace('buffhunter')
    
    for _, hl in ipairs(highlights) do
        -- Buffer number
        vim.api.nvim_buf_set_extmark(popup_buf, ns, hl.line, hl.number.start_col, {
            end_col = hl.number.end_col,
            hl_group = "Number"
        })
        
        -- File icon (if exists)
        if hl.icon.hl ~= "" then
            vim.api.nvim_buf_set_extmark(popup_buf, ns, hl.line, hl.icon.start_col, {
                end_col = hl.icon.end_col,
                hl_group = hl.icon.hl
            })
        end
        
        -- File path
        vim.api.nvim_buf_set_extmark(popup_buf, ns, hl.line, hl.path.start_col, {
            end_col = hl.path.end_col,
            hl_group = "Number"
        })
        
        -- Git status (if exists) - WIP -
        if hl.git.hl ~= "" then
            vim.api.nvim_buf_set_extmark(popup_buf, ns, hl.line, hl.git.start_col, {
                end_col = hl.git.end_col,
                hl_group = hl.git.hl,
                hl_mode = "combine"  -- This ensures only specified attributes are applied
            })
        end
    end

    -- Set keymaps
    local keymap_opts = { noremap = true, silent = true }
    local keymaps = {
        [M.config.keymaps.move_down] = 'move_selection(-1)',
        [M.config.keymaps.move_up] = 'move_selection(1)',
        ['<CR>'] = 'open_selected_buffer()',
        [M.config.keymaps.delete] = 'close_selected_buffer()',
        [M.config.keymaps.close] = 'close()',
        [M.config.keymaps.hsplit] = 'open_in_split("s")',
        [M.config.keymaps.vsplit] = 'open_in_split("v")',
        ['<Esc>'] = 'close()'
    }
    
    for key, action in pairs(keymaps) do
        vim.api.nvim_buf_set_keymap(popup_buf, 'n', key, 
            string.format([[<cmd>lua require('buffhunter').%s<CR>]], action), 
            keymap_opts)
    end

    M.highlight_selection()
    vim.bo[popup_buf].modifiable = false

    -- Center the view on the selected buffer
    vim.schedule(function()
        if popup_win and vim.api.nvim_win_is_valid(popup_win) then
            vim.api.nvim_win_set_cursor(popup_win, {selected_line, 0})
            vim.cmd('normal! zz')
        end
    end)
end

M.highlight_selection = function()
    if popup_buf then
        local ns = vim.api.nvim_create_namespace('buffhunter_selection')
        vim.api.nvim_buf_clear_namespace(popup_buf, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(popup_buf, ns, selected_line - 1, 0, {
            end_line = selected_line - 1,
            hl_group = 'Visual',
            line_hl_group = 'Visual'
        })
    end
end


M.move_selection = function(direction)
    if #buffers > 0 then
        selected_line = math.max(1, math.min(selected_line + direction, #buffers))
        M.highlight_selection()
        
        -- Add auto-scrolling
        if popup_win and vim.api.nvim_win_is_valid(popup_win) then
            local win_height = vim.api.nvim_win_get_height(popup_win)
            local current_top = vim.api.nvim_win_get_position(popup_win)[1]
            local cursor_pos = selected_line - 1
            
            -- Check if selection is near bottom
            if cursor_pos >= current_top + win_height - 2 then
                vim.api.nvim_win_set_cursor(popup_win, {selected_line, 0})
                vim.cmd('normal! zz')  -- Center the cursor line
            -- Check if selection is near top
            elseif cursor_pos <= current_top + 2 then
                vim.api.nvim_win_set_cursor(popup_win, {selected_line, 0})
                vim.cmd('normal! zz')  -- Center the cursor line
            end
        end
    end
end


M.close = function()
    if popup_win and vim.api.nvim_win_is_valid(popup_win) then
        vim.api.nvim_win_close(popup_win, true)
    end
    popup_win = nil
    popup_buf = nil
end

M.toggle = function()
    if popup_win and vim.api.nvim_win_is_valid(popup_win) then
        M.close()
    else
        M.open()
    end
end

M.open_selected_buffer = function()
    if #buffers > 0 then
        local selected_bufnr = buffers[selected_line].bufnr
        
        if original_win and vim.api.nvim_win_is_valid(original_win) then
            M.close()
            pcall(function()
                vim.api.nvim_set_current_win(original_win)
                vim.api.nvim_set_current_buf(selected_bufnr)
            end)
        else
            M.close()
            pcall(vim.api.nvim_set_current_buf, selected_bufnr)
        end
    end
end

-- Add new function for opening in split ( v or s for vertical and horizontal)
M.open_in_split = function(orientation)
    if #buffers > 0 then
        local selected_bufnr = buffers[selected_line].bufnr
        local split_cmd = ""
        if orientation == "s" then 
            split_cmd = "split"
        elseif orientation == "v" then
            split_cmd = "vsplit"
        end

        if original_win and vim.api.nvim_win_is_valid(original_win) then
            M.close()
            pcall(function()
                vim.api.nvim_set_current_win(original_win)
                vim.cmd(split_cmd)
                vim.api.nvim_set_current_buf(selected_bufnr)
            end)
        else
            M.close()
            vim.cmd(split_cmd)
            pcall(vim.api.nvim_set_current_buf, selected_bufnr)
        end
    end
end


-- Closing a buffer from the list by pressing 'x' or what current keyind is
M.close_selected_buffer = function()
    if #buffers > 0 then
        -- Delete the selected buffer
        local selected_bufnr = buffers[selected_line].bufnr
        vim.api.nvim_buf_delete(selected_bufnr, { force = true })

        -- Refresh the list and highlight - PEEK ENGINEERING CODE - MASTER LEVEL
        M.toggle()
        M.toggle()

        selected_line = math.min(selected_line, #buffers)  -- Ensure valid selection
        M.highlight_selection()  -- Reapply selection highlight
    end
end


return M
