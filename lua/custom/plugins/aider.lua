vim.api.nvim_set_keymap('n', '<leader>oa', '<cmd>lua AiderOpen()<cr>', { noremap = true, silent = true })

return {
  'joshuavial/aider.nvim',
  config = function()
    require("aider").setup {
      auto_manage_context = true,
      default_bindings = false
    }
  end,
}
