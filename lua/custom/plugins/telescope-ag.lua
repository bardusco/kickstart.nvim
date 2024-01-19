return {
    "kelly-lin/telescope-ag",
    config = function()
        local telescope_ag = require("telescope-ag")
        pcall(require('telescope').load_extension, 'ag')
        telescope_ag.setup({
            cmd = telescope_ag.cmds.rg, -- defaults to telescope_ag.cmds.ag
        })
    end,
    dependencies = { "nvim-telescope/telescope.nvim" },
}
