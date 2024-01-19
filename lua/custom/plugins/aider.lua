vim.api.nvim_set_keymap('n', '<leader>oa', '<cmd>lua AiderOpen()<cr>', { noremap = true, silent = true })

vim.g.lualine_x = {
  {
    aider_idle,
    color = { fg = '#8FBCBB' },
    cond = function()
      return _G.aider_background_status == 'idle'
    end
  },
  {
    aider_working,
    color = { fg = '#BF616A' },
    cond = function()
      return _G.aider_background_status == 'working'
    end
  }
}
return {
  'joshuavial/aider.nvim',
  config = function()
    require('aider').setup({
      auto_manage_context = true,
      default_bindings = false
    })
  end,
}
