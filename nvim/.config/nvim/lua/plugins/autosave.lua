-- "Pocco81/auto-save.nvim",
-- enabled = true,
-- lazy = false,
-- opts = {
--   debounce_delay = 500,
--   execution_message = {
--     message = function()
--       return ""
--     end,
--   },
-- },
-- keys = {
--   { "<leader>uv", "<cmd>ASToggle<CR>", desc = "Toggle autosave" },
-- },

return {
  "pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  config = function()
    require("auto-save").setup({
      enabled = true,
      execution_message = {
        message = function()
          return ""
        end,
      },
      condition = function(buf)
        -- Validate buffer exists and is valid
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end

        local filetype = vim.bo[buf].filetype

        -- List of filetypes to enable auto-save for
        local enabled_fts = { "todo", "markdown" }

        -- List of filetypes to explicitly disable
        local disabled_fts = { "sh" }

        -- Helper function to check if value is in table
        local function contains(table, val)
          for _, v in ipairs(table) do
            if v == val then
              return true
            end
          end
          return false
        end

        -- Disable for explicitly disabled filetypes
        if contains(disabled_fts, filetype) then
          return false
        end

        -- Enable only for enabled filetypes
        if contains(enabled_fts, filetype) then
          return true
        end

        -- Disable for all other filetypes
        return false
      end,
    })
  end,
}
