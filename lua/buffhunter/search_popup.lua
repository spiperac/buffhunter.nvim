SearchPopup = {}

local config = nil -- This will hold the shared configuration

-- Setup function to receive the configuration
SearchPopup.setup = function(shared_config)
    config = shared_config
end

SearchPopup.open = function () 
  -- Calculate the dimensions and position of the search input window
--
  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local search_height = 1
  local search_width = width -- Match the width of the main popup
  local search_row = row + height -- Position it directly below the main popup
  local search_col = col -- Align it horizontally with the main popup

  -- Create a buffer for the search input
  local search_buf = vim.api.nvim_create_buf(false, true)

  -- Define options for the search input window
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
      zindex = 51, -- Place it above the main popup
  }

  -- Open the search input window
  local search_win = vim.api.nvim_open_win(search_buf, true, search_opts)

  -- Optional: Configure the buffer for the search input
  vim.bo[search_buf].buftype = "prompt"
  vim.fn.prompt_setprompt(search_buf, "> ")

end 

return SearchPopup
