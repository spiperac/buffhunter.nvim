local Buffers = {}

Buffers.get_open_buffers = function()
    local buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
            local name = vim.api.nvim_buf_get_name(buf)
            table.insert(buffers, {
                bufnr = buf,
                name = name == "" and "[No Name]" or name,
            })
        end
    end
    return buffers
end

return Buffers

