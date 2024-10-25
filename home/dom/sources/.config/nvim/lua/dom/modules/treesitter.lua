local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  ensure_installed = {
    'nix',
    'vim',
    'lua',
    'bash',
    'json',
    'yaml',
    'dockerfile',
    'terraform',
    'toml',
    'html',
    'css',
    'javascript',
    'typescript',
    'tsx',
    'angular',
    'markdown',
    'latex',
    'c',
    'cpp',
    'c_sharp',
    'python',
    'rust',
    'swift',
  },
  auto_install = true,
  highlight = {
    enable = true,
  },
})
