vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
vim.api.nvim_set_keymap('n', '<Tab>', ':Neotree toggle<CR>', { noremap = true, silent = true })

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim",
  },
  config = function()
    require('neo-tree').setup {
      window = {
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        }
      }
    }
  end,
}
