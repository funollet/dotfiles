return {
  {
    "freitass/todo.txt-vim",
    enabled = true,
    config = function()
      -- set mapping when a todo.txt buffer gets its filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "todo",
        callback = function(args)
          -- args.buf is the buffer number; buffer=true makes this mapping buffer-local
          vim.keymap.set(
            "n",
            "<localleader>sc",
            ":%call todo#txt#sort_by_context()<CR>",
            { silent = true, buffer = args.buf, desc = "sort by +context" }
          )
          vim.keymap.set(
            "n",
            "<localleader>ss",
            ":%call todo#txt#sort_by_project()<CR>",
            { silent = true, buffer = args.buf, desc = "sort by @project" }
          )
          vim.keymap.set(
            "v",
            "<localleader>sc",
            ":call todo#txt#sort_by_context()<CR>",
            { silent = true, buffer = args.buf, desc = "sort by @context" }
          )
          vim.keymap.set(
            "v",
            "<localleader>sp",
            ":call todo#txt#sort_by_project()<CR>",
            { silent = true, buffer = args.buf, desc = "sort by +project" }
          )
        end,
      })
    end,
  },
}
