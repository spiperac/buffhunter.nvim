local search_popup = require("buffhunter.search_popup")
local list_popup = require("buffhunter.list_popup")
local buffers = require("buffhunter.bufferlist")

local M = {}
local config = {
    width = 0.7,
    height = 0.4,
    border = "double",
    icons = true,
    git_signs = true,
    keymaps = {
        close = "<ESC>",
        move_up = "k",
        move_down = "j",
        select = "<CR>",
        delete = "x",
        hsplit = "s",
        vsplit = "v"
    }
}

M.config = config

-- Shared state
local shared_state = {
    buffers = {},
    filtered_buffers = {},
    query = "",
    selected = 1,
    list_win = nil,
    search_win = nil,
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Set up initial state
  shared_state.buffers = buffers.get_buffers()
  shared_state.query = ""
  local keymap_opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap('n', '<ESC>', ':lua require("buffhunter").close()<CR>', keymap_opts)
  -- Initialize both popups with shared state
  search_popup.setup(M.config, shared_state)
  list_popup.setup(M.config, shared_state)
  
  -- Create command
  vim.api.nvim_create_user_command('BuffHunter', function()
    require('buffhunter').toggle()
  end, {})
end

M.toggle = function()
  if shared_state.list_win and vim.api.nvim_win_is_valid(shared_state.list_win) then
    list_popup.close()
    search_popup.close()
  else
    local list_win_pos = list_popup.open()
    shared_state.search_win = search_popup.open(list_win_pos)
  end
end

M.close = function()
  list_popup.close()
  search_popup.close()
end

return M
