local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

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
vim.opt.wrap = false -- 'nowrap' is set by disabling 'wrap'
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Save undo history
vim.opt.undofile = true
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300
-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'
-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = 'unnamedplus'

vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n', '<leader>pv', ':Vex<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader><CR>', ':so ~/.config/nvim/init.lua<CR>', { noremap = true })

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

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

require('lazy').setup({
  { 'VonHeikemen/lsp-zero.nvim', branch = 'v3.x' },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local opts = { buffer = event.buf }
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- Jump to the definition of the word under your cursor
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          -- Find references for the word under your cursor
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          --  Useful when your language has ways of declaring types without an actual implementation
          map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          -- Jump to the type of the word under your cursor
          map('go', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          -- Fuzzy find all the symbols in your current document
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          -- Rename the variable under your cursor
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          -- Opens a popup that displays documentation about the word under your cursor
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          --vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          --vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          --vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          --vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          --vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end,
      })
    end,
  },
  { 'hrsh7th/cmp-nvim-lsp' },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        --dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        -- {
        --   'rafamadriz/friendly-snippets',
        --   config = function()
        --     require('luasnip.loaders.from_vscode').lazy_load()
        --   end,
        -- },
        --},
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- read `:help ins-completion`
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'copilot' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  { 'L3MON4D3/LuaSnip' },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme('tokyonight-night')
    end
  },
  { 'projekt0n/github-nvim-theme' },
  { 'nvim-lua/plenary.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>' },
      { '<leader>fw', '<cmd>Telescope grep_string<CR>' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>' },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        pickers = {
          live_grep = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            additional_args = function(_)
              return { "--hidden" }
            end
          },
          find_files = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            hidden = true
          }

        },
        extensions = {
          "fzf"
        },
      })
      telescope.load_extension("fzf")
    end,
  },
  { 'sbdchd/neoformat' },
  { 'github/copilot.vim' },
  { 'vim-ruby/vim-ruby' },
  { 'tpope/vim-rails' },
  { 'dense-analysis/ale' },
  { 'tpope/vim-fugitive' },
  { 'prettier/vim-prettier' },
  {
    'tyru/open-browser-github.vim',
    dependencies = { 'tyru/open-browser.vim' }
  },
  { 'whiteinge/diffconflicts' },
  {
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    version = '1.9.0',
    config = function()
      local function nvim_tree_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set('n', '<C-t>',
          function() api.tree.toggle({ path = "<args>", find_file = false, update_root = false, focus = true, }) end,
          opts('Toggle'))
      end
      require("nvim-tree").setup({
        on_attach = nvim_tree_on_attach,
        view = {
          side = 'right',
          number = true,
          relativenumber = true,
          adaptive_size = true,
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
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("lazygit")
    end,
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>tt",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>tT",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      "f-person/git-blame.nvim"
    },
    config = function()
      local git_blame = require('gitblame')
      vim.g.gitblame_display_virtual_text = 0
      vim.g.gitblame_message_template = '<author> • <date>'
      vim.g.gitblame_date_format = '%r'

      local trouble = require('trouble')
      local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        -- The following line is needed to fix the background color
        -- Set it to the lualine section you want to use
        hl_group = "lualine_c_normal",
      })

      local colors = {
        cyan  = '#79dac8',
        black = '#080808',
        white = '#c6c6c6',
        red   = '#ff5189',
        grey  = '#303030',
      }

      local theme = {
        normal = {
          a = { fg = colors.white, bg = colors.grey },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white },
        },

        insert = { a = { fg = colors.white, bg = colors.grey } },
        visual = { a = { fg = colors.black, bg = colors.cyan } },
        replace = { a = { fg = colors.black, bg = colors.red } },

        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white },
        },
      }

      require('lualine').setup({
        options = {
          theme = theme,
          icons_enabled = vim.g.have_nerd_font,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            { symbols.get, cond = symbols.has }
          },
          lualine_x = {
            { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
          },
          lualine_y = { 'branch' },
          lualine_z = { 'filename' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
      })
    end,
  },
  {
    'RRethy/vim-illuminate',
    keys = {
      {
        "<C-i>",
        "<cmd>IlluminateToggle<cr>",
        desc = "Toggle Illuminate",
      }
    }
  },
  { 'preservim/nerdcommenter' },
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require('harpoon').setup()
      harpoon:setup({})

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

      -- basic telescope configuration
      local conf = require("telescope.config").values

      local function toggle_telescope(harpoon_files)
        local finder = function()
          local file_paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
          end

          return require("telescope.finders").new_table({
            results = file_paths,
          })
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = finder(),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            map("i", "<C-d>", function()
              local state = require("telescope.actions.state")
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)

              table.remove(harpoon_files.items, selected_entry.index)
              current_picker:refresh(finder())
            end)
            return true
          end,
        }):find()
      end

      vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })
    end,
  }
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '➲',
      event = '☁',
      ft = '↳',
      init = '☼',
      keys = '',
      plugin = '☇',
      runtime = '⌨',
      require = '',
      source = '⇪',
      start = '☑',
      task = '☐',
      lazy = '☾ ',
    },
  },
})

vim.cmd.filetype('plugin indent on')

vim.g['prettier#prettier_autoformat'] = 1
vim.g['prettier#autoformat_config_present'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0

-- Reserve a space in the gutter
-- This will avoid an annoying layout shift in the screen
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- LSP configuration
local servers = {
  ruby_lsp = {},
  sorbet = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
    },
  },
  bashls = {},
  cssls = {},
  html = {},
  jsonls = {},
  vtsls = {
    typescript = { tsserver = { maxTsServerMemory = 8192 } },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- vim-ruby | vim-rails settings for ruby and eruby filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function()
    vim.g.rubycomplete_buffer_loading = 1
    vim.g.rubycomplete_classes_in_global = 1
    vim.g.rubycomplete_rails = 1
  end
})
