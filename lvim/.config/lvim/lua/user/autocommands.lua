-- Autocommands (https://neovim.io/doc/user/autocmd.html)
--
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.tfstate", "*.tfstate.backup" },
  command = "set ft=json",
})
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "Jenkinsfile", "Jenkinsfile.*" },
--   command = "set ft=groovy",
-- })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
