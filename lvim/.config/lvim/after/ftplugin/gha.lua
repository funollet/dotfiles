-- github actions

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "actionlint", filetypes = { "yaml.gha" } }
  --  -ignore SC2086 -ignore SC2129
}
