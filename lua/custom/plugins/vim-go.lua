return {
  'fatih/vim-go', -- O plugin vim-go é o principal plugin Go para (Neo)vim.
  lazy = false,   -- Carrega o plugin sem atraso; pode ajustar conforme a necessidade.
  config = function()
    -- Configuração do vim-go
    vim.g.go_fmt_command = "goimports"          -- Exemplo: configura goimports como ferramenta de formatação
    vim.g.go_highlight_fields = true            -- Destaca campos de estruturas
    vim.g.go_highlight_functions = true         -- Destaca nomes de funções
    vim.g.go_highlight_methods = true           -- Destaca métodos
    vim.g.go_highlight_operators = true         -- Destaca operadores
    vim.g.go_highlight_structs = true           -- Destaca structs
    vim.g.go_highlight_types = true             -- Destaca tipos
    vim.g.go_highlight_build_constraints = true -- Destaca restrições de compilação

    -- Configuração adicional para LSP ou outras ferramentas Go, como gopls, pode ser adicionada aqui.
    -- A configuração específica do LSP dependerá do seu ambiente e preferências.
    -- Para configurações LSP detalhadas, você pode precisar integrar com nvim-lspconfig ou similar.
  end,
}
