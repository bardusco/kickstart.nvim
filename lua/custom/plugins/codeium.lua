return {
  'Exafunction/codeium.vim',
  event = 'BufEnter',
  config = function()
    -- Change '<C-g>' here to any keycode you like.
    vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    vim.keymap.set('i', '<C-k>', function() return vim.fn['codeium#CycleCompletions'](1) end,
      { expr = true, silent = true })
    vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end,
      { expr = true, silent = true })
    vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    -- vim.o.statusline = vim.o.statusline .. "%3{codeium#GetStatusString()}"

    -- Lualine integration
    local status_ok, lualine = pcall(require, 'lualine')
    if not status_ok then return end

    local lualine_status = lualine.get_config()
    table.insert(lualine_status.sections.lualine_c,
      { function() return 'codeium: ' .. vim.fn['codeium#GetStatusString']() end })
    lualine.setup(lualine_status)
  end
}
