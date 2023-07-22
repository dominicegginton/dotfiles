local cmp = require('cmp')
local cmp_under_comparator = require('cmp-under-comparator')
local luasnip = require('luasnip')
local vscode_loaders = require('luasnip.loaders.from_vscode')

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vscode_loaders.lazy_load()
local cmp_expand = function(args) luasnip.lsp_expand(args.body) end
cmp.setup({
  snippit = { expand = cmp_expand },
  window = { documentation = cmp.config.window.bordered() },
  formatting = { fields = { 'menu', 'abbr', 'kind' } },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
  }, {
    { name = 'buffer' },
  }),
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp_under_comparator.under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})
