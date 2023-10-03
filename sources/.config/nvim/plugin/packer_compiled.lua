-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/dom.egginton/.cache/nvim/packer_hererocks/2.1.1693350652/share/lua/5.1/?.lua;/Users/dom.egginton/.cache/nvim/packer_hererocks/2.1.1693350652/share/lua/5.1/?/init.lua;/Users/dom.egginton/.cache/nvim/packer_hererocks/2.1.1693350652/lib/luarocks/rocks-5.1/?.lua;/Users/dom.egginton/.cache/nvim/packer_hererocks/2.1.1693350652/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/dom.egginton/.cache/nvim/packer_hererocks/2.1.1693350652/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["cmp-under-comparator"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp-under-comparator",
    url = "https://github.com/lukas-reineke/cmp-under-comparator"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["copilot.vim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  ["diffview.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["dressing.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  ["dropbar.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/dropbar.nvim",
    url = "https://github.com/bekaboo/dropbar.nvim"
  },
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/editorconfig-vim",
    url = "https://github.com/editorconfig/editorconfig-vim"
  },
  ["fidget.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/fidget.nvim",
    url = "https://github.com/j-hui/fidget.nvim"
  },
  ["fine-cmdline.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/fine-cmdline.nvim",
    url = "https://github.com/VonHeikemen/fine-cmdline.nvim"
  },
  ["focus.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/focus.nvim",
    url = "https://github.com/nvim-focus/focus.nvim"
  },
  ["formatter.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/formatter.nvim",
    url = "https://github.com/mhartington/formatter.nvim"
  },
  ["fsread.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/fsread.nvim",
    url = "https://github.com/nullchilly/fsread.nvim"
  },
  ["github-nvim-theme"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/github-nvim-theme",
    url = "https://github.com/projekt0n/github-nvim-theme"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  harpoon = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/theprimeagen/harpoon"
  },
  ["hbac.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/hbac.nvim",
    url = "https://github.com/axkirillov/hbac.nvim"
  },
  luasnip = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/luasnip",
    url = "https://github.com/l3mon4d3/luasnip"
  },
  ["markdown-preview.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["mini.comment"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.comment",
    url = "https://github.com/echasnovski/mini.comment"
  },
  ["mini.cursorword"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.cursorword",
    url = "https://github.com/echasnovski/mini.cursorword"
  },
  ["mini.hipatterns"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.hipatterns",
    url = "https://github.com/echasnovski/mini.hipatterns"
  },
  ["mini.indentscope"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.indentscope",
    url = "https://github.com/echasnovski/mini.indentscope"
  },
  ["mini.move"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.move",
    url = "https://github.com/echasnovski/mini.move"
  },
  ["mini.sessions"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.sessions",
    url = "https://github.com/echasnovski/mini.sessions"
  },
  ["mini.starter"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.starter",
    url = "https://github.com/echasnovski/mini.starter"
  },
  ["mini.statusline"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.statusline",
    url = "https://github.com/echasnovski/mini.statusline"
  },
  ["mini.tabline"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.tabline",
    url = "https://github.com/echasnovski/mini.tabline"
  },
  ["mini.trailspace"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mini.trailspace",
    url = "https://github.com/echasnovski/mini.trailspace"
  },
  ["mkdir.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/mkdir.nvim",
    url = "https://github.com/jghauser/mkdir.nvim"
  },
  neogit = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/neogit",
    url = "https://github.com/neogitorg/neogit"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/muniftanjim/nui.nvim"
  },
  ["nvim-blame-line"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-blame-line",
    url = "https://github.com/tveskag/nvim-blame-line"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-code-action-menu"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-code-action-menu",
    url = "https://github.com/weilbith/nvim-code-action-menu"
  },
  ["nvim-dap"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-dap-python"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-dap-python",
    url = "https://github.com/mfussenegger/nvim-dap-python"
  },
  ["nvim-dap-ui"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-dap-ui",
    url = "https://github.com/rcarriga/nvim-dap-ui"
  },
  ["nvim-dap-virtual-text"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-dap-virtual-text",
    url = "https://github.com/thehamsta/nvim-dap-virtual-text"
  },
  ["nvim-dap-vscode-js"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-dap-vscode-js",
    url = "https://github.com/mxsdev/nvim-dap-vscode-js"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-ufo"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-ufo",
    url = "https://github.com/kevinhwang91/nvim-ufo"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["package-info.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/package-info.nvim",
    url = "https://github.com/vuki656/package-info.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["promise-async"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/promise-async",
    url = "https://github.com/kevinhwang91/promise-async"
  },
  ["renamer.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/renamer.nvim",
    url = "https://github.com/filipdutescu/renamer.nvim"
  },
  ripgrep = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/ripgrep",
    url = "https://github.com/burntsushi/ripgrep"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/folke/trouble.nvim"
  },
  ["true-zen.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/true-zen.nvim",
    url = "https://github.com/pocco81/true-zen.nvim"
  },
  ["vim-dadbod"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/vim-dadbod",
    url = "https://github.com/tpope/vim-dadbod"
  },
  ["vim-dadbod-completion"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/vim-dadbod-completion",
    url = "https://github.com/kristijanhusak/vim-dadbod-completion"
  },
  ["vim-dadbod-ui"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/vim-dadbod-ui",
    url = "https://github.com/kristijanhusak/vim-dadbod-ui"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator",
    url = "https://github.com/christoomey/vim-tmux-navigator"
  },
  ["vscode-js-debug"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/opt/vscode-js-debug",
    url = "https://github.com/microsoft/vscode-js-debug"
  },
  ["which-key.nvim"] = {
    loaded = true,
    path = "/Users/dom.egginton/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
