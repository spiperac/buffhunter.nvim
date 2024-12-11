-- formatter.lua
local M = {}

M.format_buffer_line = function(buffer, opts)
    local padding = math.floor(vim.o.columns * 0.7)
 - #buffer.name - #buffer.icon - 10
    if padding < 0 then padding = 0 end
    
    local parts = {}
    
    -- Table of buffers
    table.insert(parts, buffer.indicator)
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

M.make_highlights = function(popup_buf, highlights, ns)
    
    
    for _, hl in ipairs(highlights) do
        -- Buffer number
        vim.api.nvim_buf_set_extmark(popup_buf, ns, hl.line, hl.number.start_col, {
            end_col = hl.number.end_col,
            hl_group = "Number"
        })
        
        -- File icon (if exists)
        if hl.icon.hl ~= "" then
            print(hl.icon.hl)
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
        
    end
end

return M
