require('user/set')
require('user/remap')
require('alpha').setup(require'alpha.themes.startify'.config)
require('colorizer').setup()
require('which-key').setup()
require('lualine').setup {
  options = {theme = 'gruvbox-material'}
}

local nvimTree = require('nvim-tree')
nvimTree.setup {
  view = {
    adaptive_size = true
  },
  renderer = {
    group_empty = true,
  }
}

require('gitsigns').setup {
  current_line_blame = true,
  numhl = true
}

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
require('ibl').setup()
require('nvim-autopairs').setup()
require('nvim-web-devicons').setup {
  default = true;
}
require('Comment').setup()
require('fidget').setup()
require('scrollbar').setup {
  handlers = {
    cursor = false
  }
}
require("scrollbar.handlers.gitsigns").setup()
require('crates').setup()

-- Setup nvim-cmp.
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), 
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua require"telescope.builtin".lsp_definitions({initial_mode="normal"})<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua require"telescope.builtin".lsp_implementations({initial_mode="normal"})<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua require"telescope.builtin".lsp_references({initial_mode="normal"})<CR>', opts)
  buf_set_keymap('n', 'gws', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', opts)
  buf_set_keymap('n', 'gds', '<cmd>Telescope lsp_document_symbols<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>cf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { buffer = bufnr, desc = 'Toggle Inlay Hints' })
  end

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer', 'hls', 'roc_ls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities
  }
end

nvim_lsp.nil_ls.setup {
  flags = {
    debounce_text_changes = 150,
  },
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" }
      }
    }
  }
}

-- Metals
vim.cmd([[augroup lsp]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType scala setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
vim.cmd([[autocmd FileType java,scala,sbt lua require("metals").initialize_or_attach(metals_config)]])
vim.cmd([[augroup end]])

metals_config = require("metals").bare_config()
metals_config.on_attach = on_attach
metals_config.settings = {
  useGlobalExecutable = true,
  inlayHints = {
    hintsInPatternMatch = { enable = true },
    implicitArguments = { enable = true },
    inferredTypes = { enable = true },
  }
}

metals_config.capabilities = capabilities

vim.diagnostic.config({ virtual_text = true })
