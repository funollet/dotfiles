-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = false

-- Fold with treesitter.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- Start with all folds open.
vim.opt.foldenable = false

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

lvim.builtin.illuminate.active = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "dot",
  "gitattributes",
  "gitignore",
  "git_rebase",
  "go",
  "hcl",
  "html",
  "http",
  "java",
  "javascript",
  "json",
  "jsonnet",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "rst",
  "rust",
  "sql",
  "todotxt",
  "toml",
  "typescript",
  "vim",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell", "tsx" }
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.rainbow.enable = true

-- Additional Plugins

lvim.plugins = {
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },
  { "yasuhiroki/github-actions-yaml.vim" },
  { "NoahTheDuke/vim-just" },
  -- {
  --   "nvim-telescope/telescope-project.nvim",
  --   event = "BufWinEnter",
  --   setup = function()
  --     vim.cmd [[packadd telescope.nvim]]
  --   end,
  -- },
  -- {
  --   "mrjones2014/nvim-ts-rainbow",
  -- },
    -- {
    --   "folke/trouble.nvim",
    --   cmd = "TroubleToggle",
    -- },
}