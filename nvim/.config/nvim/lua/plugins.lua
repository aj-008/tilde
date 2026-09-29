require("lazy").setup({
  -- FZF
  { 'junegunn/fzf', build = './install --bin' },
  { 'junegunn/fzf.vim', dependencies = { 'junegunn/fzf' } },

  -- Statusline
  'itchyny/lightline.vim',

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  -- LSP
  'neovim/nvim-lspconfig',

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets', -- replaces vim-snippets
    },
  },

  -- LaTeX
  {
    'lervag/vimtex',
    ft = 'tex',
    version = 'v2.15',
    config = function()
      vim.g.vimtex_enabled = 1
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_imaps_enabled = 1
      vim.g.vimtex_matchparen_enabled = 1
    end
  },

    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = function()
        local npairs = require('nvim-autopairs')
        local Rule = require('nvim-autopairs.rule')
        npairs.setup({ check_ts = true })

        npairs.add_rules({
          Rule('$', '$', 'tex'):with_move(function(opts)
            return opts.char == '$'
          end),
        })
      end
    },

    {
      'kylechui/nvim-surround',
      version = '*',
      event = "VeryLazy",
      config = function() require('nvim-surround').setup({}) end
    },

    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },

  -- Rust
  {
    'mrcjkb/rustaceanvim',
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = true,
              check = { command = "clippy" },
            },
          },
        },
      }
    end,
  },
  { 'saecki/crates.nvim', event = 'BufRead Cargo.toml', config = true },

  -- Web dev
  'evanleck/vim-svelte',
  'mattn/emmet-vim',
  
    -- lazy.nvim spec
    {
      'akinsho/flutter-tools.nvim',
      lazy = false,
      dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim',
      },
      config = function()
        require('flutter-tools').setup({
          lsp = {
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
            document_color = {
              enabled = true,
            },
            settings = {
              showTodos = true,
              completeFunctionCalls = true,
            },
          },
          widget_guides = { enabled = true },
          dev_log = { open_cmd = 'tabedit' },
          outline = { open_cmd = '30vnew' },
        })
      end,
    }

})
