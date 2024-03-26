-- keymappings [view all the defaults by pressing <leader>Lk]
--
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )
--
lvim.leader = "space"

lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

lvim.keys.insert_mode["jk"] = "<ESC>"
lvim.keys.insert_mode["JK"] = "<ESC>"
-- lvim.keys.normal_mode["jk"] = "<C-C>"
--
lvim.keys.normal_mode["ff"] = "za<cr>"

-- Show next matched string at the center of screen.
lvim.keys.normal_mode["n"] = "nzzzv"
lvim.keys.normal_mode["N"] = "Nzzzv"
lvim.keys.normal_mode["J"] = "mzJ`z"

-- Window navigation.
-- Navigate the split view easier by pressing CTRL+j, CTRL+k, CTRL+h, or CTRL+l.
lvim.keys.normal_mode["<c-j>"] = "<c-w>j"
lvim.keys.normal_mode["<c-k>"] = "<c-w>k"
lvim.keys.normal_mode["<c-h>"] = "<c-w>h"
lvim.keys.normal_mode["<c-l>"] = "<c-w>l"
-- lvim.keys.normal_mode["<c-w><c-w>"] = ""

-- disable increment/decrement numbers
lvim.keys.normal_mode["<C-a>"] = "<Nop>"
lvim.keys.normal_mode["<C-x>"] = "<Nop>"


-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

local wk = lvim.builtin.which_key

-- folds
lvim.builtin.which_key.setup.plugins.presets.z = true

-- Use which-key to add extra bindings with the leader-key prefix
wk.mappings["sP"] = { "<cmd>Telescope projects<CR>", "Projects" }
wk.mappings["gt"] = { "<cmd>call jobstart('konsole')<CR>", "Spawn new terminal" }
wk.mappings["t"] = {
  name = "+Toggle",
  h = { "<cmd>set list!<cr>", "hidden" },
  i = { "<cmd>IlluminateToggle<cr>", "illuminate" },
  c = { "<cmd>lua require('cmp').setup.buffer { enabled = false }<cr>", "cmp disable"},
  d = { "<cmd>lua if vim.diagnostic.is_disabled(0) then vim.diagnostic.enable(0) else vim.diagnostic.disable(0) end<cr>", "diagnostics" },
}
wk.mappings['T'] = {}
-- wk.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
-- }
