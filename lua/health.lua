local M = {}

function M.check()
  local health = vim.health or require("health")
  
  health.report_start("BuffHunter")

  -- Check Neovim version
  if vim.fn.has("nvim-0.7.0") == 1 then
    health.report_ok("Neovim version >= 0.7.0")
  else
    health.report_error("Neovim version must be >= 0.7.0")
  end

  -- Check for optional dependencies
  local has_devicons, _ = pcall(require, "nvim-web-devicons")
  if has_devicons then
    health.report_ok("nvim-web-devicons found")
  else
    health.report_warn("nvim-web-devicons not found (optional)")
  end

  local has_gitsigns, _ = pcall(require, "gitsigns")
  if has_gitsigns then
    health.report_ok("gitsigns.nvim found")
  else
    health.report_warn("gitsigns.nvim not found (optional)")
  end
end

return M
