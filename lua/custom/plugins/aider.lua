return {
  'joshuavial/aider.nvim',
  config = function()
    require("aider").setup {
      auto_manage_context = false,
      default_bindings = true
    }
  end,
}
