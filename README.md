# BuffHunter

BuffHunter is a lightweight and highly functional Neovim plugin designed to simplify buffer management. It provides an intuitive popup list of all currently opened buffers and offers a variety of actions to help you work more efficiently.

## Screenshots

![image](https://github.com/user-attachments/assets/00b2a9db-ee1f-405a-99b1-d0698b1fa08b)

## Features

- **Interactive Buffer List**: View all open buffers in a clean, easy-to-navigate popup.
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


## Usage

- Open BuffHunter: `:BuffHunter`
- Perform buffer actions directly from the popup list.
- Customize key mappings and actions through the setup function.

---

## Configuration

BuffHunter offers flexible configuration options. Below is an example:

```lua
require('buffhunter').setup {
  keymap = {
    open = '<CR>',         -- Open selected buffer
    close = 'x',           -- Close selected buffer
    split_h = 's',         -- Open in horizontal split
    split_v = 'v',         -- Open in vertical split
  },
  git_signs = true,        -- Enable Git status display
}
```
More options in init.lua.


## License

BuffHunter is licensed under the MIT License. See [LICENSE](LICENSE) for details.
