# BuffHunter

BuffHunter is a lightweight Neovim plugin designed to simplify buffer management. It provides an intuitive searchable popup list of all currently opened buffers and offers a variety of actions to help you work more efficiently.

## Screenshots

![image](https://github.com/user-attachments/assets/77912831-df66-4b8d-94dd-19d0107ccc1c)

## Features

- **Interactive Buffer List**: View all open buffers in a clean, easy-to-navigate popup.
- ** Filter buffers in the list.
- **Quick Actions**:
  - Open buffers.
  - Close buffers.
  - Open buffers in horizontal or vertical splits.
- **Git Integration**: Instantly check the Git status of each buffer.


## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'spiperac/buffhunter',
  config = function()
    require('buffhunter').setup {
      -- Add your configuration here
    }
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'spiperac/buffhunter',
  config = function()
    require('buffhunter').setup {
      -- Add your configuration here
    }
  end
}
```

Or you can create plugins/buffhunter.lua in your nvim config folder and use:
```lua
return function()
    require('buffhunter').setup {
      keymaps = {
        open = '<CR>',         -- Open selected buffer
        close = 'q',           -- Close selected buffer
        delete = 'x',
        split_h = 's',         -- Open in horizontal split
        split_v = 'v',         -- Open in vertical split
      },
      git_signs = true,        -- Enable Git status display
    }
end

```


## Usage

- Open BuffHunter: `:BuffHunter`
- Perform buffer actions directly from the popup list.
- Customize key mappings and actions through the setup function.

Additionally, you can add a keybind like:
```lua
map("n", "<C-l>", ':BuffHunter<CR>', opts)

```

And by pressint CTRL + L, BuffHunter popup window will showup.

## Configuration

BuffHunter offers flexible configuration options. Below is an example:

Example of plugins/buffhunter.lua:

```lua
return function()
    require('buffhunter').setup {
      keymaps = {
        open = '<CR>',         -- Open selected buffer
        close = 'c',           -- Close selected buffer
        split_h = 's',         -- Open in horizontal split
        split_v = 'v',         -- Open in vertical split
      },
      git_signs = true,        -- Enable Git status display
    }
end
```
More options in init.lua.


## License

BuffHunter is licensed under the MIT License. See [LICENSE](LICENSE) for details.
