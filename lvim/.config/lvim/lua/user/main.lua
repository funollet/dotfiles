-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = true

-- Fold with treesitter.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- Start with all folds open.
vim.opt.foldenable = false

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = false
-- lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.nvimtree.setup.view.adaptive_size = true

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
  {
    "ggandor/leap.nvim",
    -- Troubleshoot: overwrides x
    name = "leap",
    config = function()
      -- require("leap").add_default_mappings()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')
      -- vim.keymap.set('n', 's',  '<Plug>(leap-forward)')
      -- vim.keymap.set('n', 'S',  '<Plug>(leap-backward)')
      -- vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')
    end,
  },
  { "freitass/todo.txt-vim" },
  { "sindrets/diffview.nvim" },
  { "famiu/bufdelete.nvim" },
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup {
        -- suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
        -- log_level = "debug",
      }
    end
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "op read --no-newline op://non-interactive/OpenAI_token/credential",
        openai_params = {
          model = "chatgpt-4o-latest",
        },
        openai_edit_params = {
          model = "chatgpt-4o-latest",
        },
        actions_paths = { "~/.config/lvim/chatgpt_custom_actions.json" },
        -- predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        filetypes = {
          markdown = false,
          todo = false,
          todotxt = false,
          text = false,
          txt = false,
          csv = false,
          gitrebase = false,
          sh = function()
            if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
              return false -- disable for .env files
            end
            return true
          end,
        },
        copilot_model = "gpt-4o-copilot",
      }) -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
    end
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup()     -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
        require("copilot_cmp").setup() -- https://github.com/zbirenbaum/copilot-cmp/blob/master/README.md#configuration
      end, 100)
    end,
  }
}
