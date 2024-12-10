local Buffers = require("buffhunter.buffers") -- Import the Buffers module

ListPopup = {}

local config = nil -- This will hold the shared configuration

-- Setup function to receive the configuration
ListPopup.setup = function(shared_config)
    config = shared_config
end

ListPopup.open = function () 
  -- Calculate the dimensions and position of the search input window
--
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  -- Create a buffer for the search input
  local list_buf = vim.api.nvim_create_buf(false, true)

  -- Define options for the search input window
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
      zindex = 30, -- Place it above the main popup
  }

  -- Open the search input window
  local list_win = vim.api.nvim_open_win(list_buf, true, list_opts)

  -- Optional: Configure the buffer for the search input
  vim.bo[list_buf].buftype = "nofile"
  -- Get open buffers and populate the list popup
  local buffers = Buffers.get_open_buffers()
  local lines = {}
  for _, buffer in ipairs(buffers) do
      table.insert(lines, string.format("%d: %s", buffer.bufnr, buffer.name))
  end

  -- Set the buffer content
  vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, lines)
end 

return ListPopup
