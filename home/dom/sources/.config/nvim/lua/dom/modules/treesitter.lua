local ok_ts, treesitter = pcall(require, 'nvim-treesitter')
local ok_cfg, configs = pcall(require, 'nvim-treesitter.configs')

local languages = {
  'nix',
  'vim',
  'vimdoc',
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
}

if ok_cfg and configs then
  configs.setup({
    ensure_installed = languages,
    auto_install = true,
    highlight = {
      enable = true,
    },
  })
elseif ok_ts and treesitter then
  treesitter.setup({})
  if type(treesitter.install) == 'function' then treesitter.install(languages) end
  -- In Neovim 0.12, tree-sitter highlighting is built-in
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
  })
else
  vim.notify('nvim-treesitter not found; skipping treesitter setup', vim.log.levels.WARN)
end
