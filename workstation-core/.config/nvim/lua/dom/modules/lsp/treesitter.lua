local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  ensure_installed = {
    'vim',
    'lua',
    'bash',
    'json',
    'yaml',
    'dockerfile',
    'toml',
    'html',
    'css',
    'javascript',
    'typescript',
    'python',
    'rust',
    'swift',
  },
  auto_install = true,
  highlight = {
    enable = true,
  },
})
