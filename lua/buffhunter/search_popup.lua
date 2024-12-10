local Buffers = require("buffhunter.buffers") -- To get the initial buffer list
local ListPopup = require("buffhunter.list_popup") -- To update the list popup


SearchPopup = {}

local search_win = nil
local config = nil -- This will hold the shared configuration
local shared_state = {
    buffers = {}, -- Store the initial list of buffers
    query = "",   -- Store the current search query
}

-- Setup function to receive the configuration
SearchPopup.setup = function(shared_config)
    config = shared_config
    shared_state = state or shared_state
end

SearchPopup.open = function (list_win_pos) 

    -- Get the dimensions and position of the list window from the passed `list_win_pos`
    local list_win_height = list_win_pos.height

    -- Calculate the position for the search window directly below the list popup
    local search_height = 1
    local search_width = list_win_pos.width  -- Same width as the list window
    local search_row = list_win_pos.row + list_win_pos.height + 1  -- Place search below the list window
    local search_col = list_win_pos.col  -- Align search horizontally with list popup

    -- Create a buffer f

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
    if not search_win or not vim.api.nvim_win_is_valid(search_win) then
        search_win = vim.api.nvim_open_win(search_buf, true, search_opts)
    end

  -- Optional: Configure the buffer for the search input
  vim.fn.prompt_setprompt(search_buf, "> ")
  vim.bo[search_buf].buftype = "nofile" -- Prevent prompt behavior
  vim.api.nvim_buf_set_keymap(search_buf, "i", "<CR>", "<Nop>", { noremap = true, silent = true }) -- Disable <Enter>


  -- Add autocommand to dynamically update ListPopup on input change
  vim.api.nvim_buf_attach(search_buf, false, {
      on_lines = function()
          -- Fetch the current query from the search buffer
          local query = vim.trim(vim.api.nvim_buf_get_lines(search_buf, 0, -1, false)[1] or "")
          -- Get the list of buffers
          local buffers = Buffers.get_open_buffers()
          -- Update the list popup
          require("buffhunter.list_popup").update(buffers, query)
      end,
  })

  return search_win
end 

SearchPopup.close = function()
    print("Closing search")
     -- vim.api.nvim_win_close(search_win, true)

    if search_win and vim.api.nvim_win_is_valid(search_win) then
        vim.api.nvim_win_close(search_win, true)
    end
end

return SearchPopup
