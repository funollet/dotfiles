return {
  {
    "zbirenbaum/copilot.lua",
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      todo = false,
    },
    sh = function()
      if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
        -- disable for .env files
        return false
      end
      return true
    end,
  },
}
