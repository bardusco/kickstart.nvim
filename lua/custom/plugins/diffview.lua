return {
  'sindrets/diffview.nvim',
  event = 'BufRead',
  dependencies = { 'nvim-lua/plenary.nvim' }, -- Diffview.nvim depende de plenary.nvim
  config = function()
    -- Configuração personalizada, se necessário
    require('diffview').setup({
      diff_binaries = false,   -- Show diffs for binaries
      enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
      use_icons = true,        -- Requires nvim-web-devicons
      icons = {                -- Only applies when use_icons is true.
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      file_panel = {
        listing_style = "tree", -- One of 'list' or 'tree'
        win_config = {          -- See ':h diffview-config-win_config'
          position = "left",
          width = 35,
        },
      },
    })
  end
}
