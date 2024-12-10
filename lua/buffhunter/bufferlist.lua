-- bufferlist.lua
local M = {}
-- bufferlist.lua
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')

local function get_icon(filetype)
    if has_devicons then
        local icon = devicons.get_icon_by_filetype(filetype)
        return icon and (icon .. " ") or ""
    end
    return ""
end

M.BufferEntry = {
    new = function(bufnr, name)
        return {
            bufnr = bufnr,
            name = name,
            filetype = vim.api.nvim_buf_get_option(bufnr, "filetype"),
            icon = "", -- Can be populated by optional icon provider
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
