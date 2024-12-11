-- bufferlist.lua
local M = {}
-- bufferlist.lua
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

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
    if bufnr ~= nil then
      local status = vim.b[bufnr].gitsigns_status_dict
    end
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

M.BufferEntry = {
    new = function(bufnr, name)
        return {
            bufnr = bufnr,
            name = name ~= "" and vim.fn.fnamemodify(name, ":~:."),
            filetype = vim.api.nvim_buf_get_option(bufnr, "filetype"),
            icon = get_file_icon(name), -- Can be populated by optional icon provider
            indicator = "",
            git_sign = get_git_status(nufnr),
            modified = vim.api.nvim_buf_get_option(bufnr, "modified"),
            -- Add any other buffer metadata you want
        }
    end
}

M.get_buffers = function(opts)
    local buffers = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buflisted") then
            local name = vim.api.nvim_buf_get_name(bufnr)
            name = name ~= "" and name or "[No Name]"  -- Ensure name is never nil/empty
            local entry = M.BufferEntry.new(bufnr, name)
            table.insert(buffers, entry)
        end
    end
    return buffers
end

return M
