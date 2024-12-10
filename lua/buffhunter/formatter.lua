-- formatter.lua
local M = {}



M.format_buffer_line = function(buffer, opts)
    local padding = math.floor(vim.o.columns * 0.7)
 - #buffer.name - #buffer.icon - 8
    if padding < 0 then padding = 0 end
    
    local parts = {}
    if buffer.icon and opts.show_icons then
        table.insert(parts, buffer.icon)
    end
    
    table.insert(parts, buffer.bufnr .. ":")
    table.insert(parts, buffer.icon)
    table.insert(parts, buffer.name)
    table.insert(parts,string.rep(" ", padding))
    table.insert(parts, buffer.git_sign)

    if buffer.modified then
        table.insert(parts, "[+]")
    end
    
    return table.concat(parts, " ")
end

return M
