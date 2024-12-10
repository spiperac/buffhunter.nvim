-- formatter.lua
local M = {}

M.format_buffer_line = function(buffer, opts)
    local parts = {}
    
    if buffer.icon and opts.show_icons then
        table.insert(parts, buffer.icon)
    end
    
    table.insert(parts, buffer.bufnr .. ":")
    table.insert(parts, buffer.name)
    
    if buffer.modified then
        table.insert(parts, "[+]")
    end
    
    return table.concat(parts, " ")
end

return M
