local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not ok or not treesitter then
  vim.notify('nvim-treesitter not found; skipping treesitter setup', vim.log.levels.WARN)
  return
end

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
