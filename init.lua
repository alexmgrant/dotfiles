local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop
-- 
-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

vim.opt.scrolloff = 10
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false  -- 'nowrap' is set by disabling 'wrap'
vim.opt.mouse = 'a'
vim.opt.termguicolors = true

vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n', '<leader>pv', ':Vex<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader><CR>', ':so ~/.config/nvim/init.lua<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>:q<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>v', '<C-w>v', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>s', '<C-w>s', { noremap = true })

vim.api.nvim_set_keymap('n', '<C-j>', ':cnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':cprev<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<C-t>', ':NvimTreeToggle<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-f>', ':NvimTreeFindFile!<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>8', ':noh<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>ogf', ':OpenGithubFile<CR>', { noremap = true })

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('lazy').setup({
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
  {'folke/tokyonight.nvim'},
  {'nvim-lua/plenary.nvim'},
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8', 
    dependencies = {'nvim-lua/plenary.nvim'}
  },
  {'sbdchd/neoformat'},
  {'github/copilot.vim'},
  {'vim-ruby/vim-ruby'},
  {'tpope/vim-rails'},
  {'dense-analysis/ale'},
  {'tpope/vim-fugitive'},
  {'prettier/vim-prettier'},
  {'tyru/open-browser.vim'},
  {'tyru/open-browser-github.vim'},
  {'whiteinge/diffconflicts'},
  {'nvim-treesitter/nvim-treesitter', ['do'] = ':TSUpdate'},
  {'nvim-tree/nvim-tree.lua'}
})

vim.cmd.colorscheme('tokyonight')
vim.cmd.syntax('on')
vim.cmd.filetype('plugin indent on')

vim.g['prettier#prettier_autoformat'] = 1
vim.g['prettier#autoformat_config_present'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0

local function nvim_tree_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set('n', '<C-t>', function() api.tree.toggle({ path = "<args>", find_file = false, update_root = false, focus = true, }) end, opts('Toggle'))
end

require("nvim-tree").setup({
  on_attach = nvim_tree_on_attach,
  view = {
    side = 'right',
    number = true,
    relativenumber = true,
  },
  renderer = {
    icons = {
      show = {
        file = false,
        folder = true,
        folder_arrow = false,
      },
      git_placement = "after",
      glyphs = {
        git = {
          unstaged = "○",
          staged = "●",
          unmerged = "◑",
          renamed = "➲",
          untracked = "◍",
          deleted = "⌫",
          ignored = "◌",
        },
        folder = {
          arrow_closed = "→",
          arrow_open = "↓",
          default = "↳",
          open = "↴",
          empty = "∅",
          empty_open = "↴",
          symlink = "↔",
          symlink_open = "↕",
        },
      },
    },
  },
})

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    -- ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    -- ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    -- ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    -- ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

-- vim-ruby | vim-rails settings for ruby and eruby filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"ruby", "eruby"},
  callback = function()
    vim.g.rubycomplete_buffer_loading = 1
    vim.g.rubycomplete_classes_in_global = 1
    vim.g.rubycomplete_rails = 1
  end
})
