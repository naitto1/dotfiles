return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {
      auto_install = true,
    },
    config = true,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets'
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        formatting = lsp_zero.cmp_format({details = true}),
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
        },
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({select = false}),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })
    end
  },

  ---
  --- LSP Configuration
  ---
  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
      {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      require('mason-lspconfig').setup({
        -- Ensure these servers are installed by Mason
        ensure_installed = {
          'lua_ls',
          'pyright',  -- Python LSP server
          'clangd',   -- C/C++ LSP server
        },
        -- This table is for "custom handlers" for specific servers.
        -- If a server in 'ensure_installed' is *not* listed here,
        -- mason-lspconfig will simply call `require('lspconfig').server_name.setup({})`
        -- You only need to add an entry here if you want to pass specific options to `setup()`.
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup({})
          end,
          -- (Optional) Configure lua language server for neovim
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
          -- (Optional) Configure pyright (Python) LSP server
          pyright = function()
            -- You can add specific configurations for pyright here if needed.
            -- For example, to include a specific environment or type checking mode:
            -- require('lspconfig').pyright.setup({
            --   settings = {
            --     python = {
            --       analysis = {
            --         typeCheckingMode = "basic",
            --         autoSearchPaths = true,
            --         useLibraryCodeForTypes = true,
            --       },
            --     },
            --   },
            -- })
            require('lspconfig').pyright.setup({})
          end,
          -- (Optional) Configure clangd (C/C++) LSP server
          clangd = function()
            -- For clangd, you might want to specify compilation database paths,
            -- or enable/disable certain diagnostics.
            -- require('lspconfig').clangd.setup({
            --   cmd = {"clangd", "--background-index"},
            --   filetypes = {"c", "cpp", "objc", "objcpp"},
            -- })
            require('lspconfig').clangd.setup({})
          end,
        }
      })
    end,
  },
}
