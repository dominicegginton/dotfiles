local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  ensure_installed = {
    'vim',
    'lua',
    'bash',
    'json',
    'yaml',
    'html',
    'css',
    'javascript',
    'typescript',
    'python',
  },
  auto_install = true,
  highlight = {
    enable = true,
  },
})
