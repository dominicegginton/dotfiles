local global = vim.g
local option = vim.opt

-- GENERAL
option.mouse = 'a'
option.clipboard = 'unnamedplus'
option.swapfile = false
option.backup = false
option.completeopt = 'menuone,noinsert,noselect'

-- UI
option.number = true
option.showmatch = true
option.foldmethod = 'marker'
option.signcolumn = 'yes'
option.splitright = true
option.splitbelow = true
option.linebreak = true
option.termguicolors = false
option.laststatus = 3
option.scrolloff = 8
option.sidescrolloff = 8
option.cmdheight = 0
global.flow_strength = 0

-- TABS AND INDENTATION
option.expandtab = true
option.tabstop = 2
option.shiftwidth = 2
option.softtabstop = 2
option.smartindent = true

-- SEARCH
option.hlsearch = true
option.incsearch = true
option.ignorecase = true
option.smartcase = true

-- CLIPBOARD
option.clipboard = 'unnamedplus'

-- UNDO
option.undofile = true
option.undodir = os.getenv('HOME') .. '/.local/nvim/undo'

-- CPU, MEMORY AND PERFORMANCE
option.swapfile = false
option.backup = false
option.hidden = true
option.history = 1000
option.lazyredraw = true
option.synmaxcol = 240
option.updatetime = 250
option.timeoutlen = 500

-- NETRW
global.loaded_netrw = 1
global.loaded_netrwPlugin = 1

-- STARTUP
option.shortmess:append('sI')
