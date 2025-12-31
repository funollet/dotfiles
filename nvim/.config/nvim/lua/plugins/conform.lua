return {
  -- change plugin config
  {
    "stevearc/conform.nvim",
    -- opts will be merged with the parent spec
    opts = {
      formatters = {
        shfmt = {
          -- 4-space indent, indent case labels, tabs
          prepend_args = { "-i", "4", "-ci", "-bn" },
        },
      },
    },
  },
}
