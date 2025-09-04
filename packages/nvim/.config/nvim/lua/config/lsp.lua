local M = {}

M.setup = function()
  ----------------------------------------------------------------------
  -- 基本 UI/補完まわり（好みに応じて）
  ----------------------------------------------------------------------
  vim.opt.completeopt = { "menuone", "noselect", "popup" }

  ----------------------------------------------------------------------
  -- すべての LSP クライアントに共通の既定値
  -- - ルート判定の後ろ盾として .git を入れておく
  -- - semantic tokens の複数行対応を有効化（対応サーバは反映される）
  ----------------------------------------------------------------------
  vim.lsp.config('*', {
    root_markers = { '.git' },
    capabilities = {
      textDocument = {
        semanticTokens = { multilineTokenSupport = true },
      },
    },
  })

  ----------------------------------------------------------------------
  -- LspAttach: バッファローカルのキーマップや自動処理
  -- - 共通キーマップ
  -- - 自動補完（サーバの triggerCharacters を用いた autotrigger）
  -- - 保存時フォーマット（TS/JS は Prettier 等に任せたい想定で除外）
  ----------------------------------------------------------------------
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      local bufnr = args.buf

      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- よく使う操作
      map('n', 'gd', vim.lsp.buf.definition,        'LSP: Goto Definition')
      map('n', 'gD', vim.lsp.buf.declaration,       'LSP: Goto Declaration')
      map('n', 'gh', vim.lsp.buf.hover,             'LSP: Hover')
      map('n', 'gR', vim.lsp.buf.rename,            'LSP: Rename')
      map('n', 'gr', vim.lsp.buf.references,        'LSP: References')
      map('n', 'ga', vim.lsp.buf.code_action,       'LSP: Code Action')

      -- 自動補完（<C-y> で確定。必要なら completeopt を調整）
      if client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      end

      -- 保存時フォーマット（TS/JS は除外）
      if client:supports_method('textDocument/formatting') and client.name ~= 'ts_ls' then
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = vim.api.nvim_create_augroup('my.lsp.format.' .. bufnr, { clear = true }),
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
          end,
        })
      end
    end,
  })

  ----------------------------------------------------------------------
  -- 言語サーバ個別の定義
  -- → vim.lsp.config('<name>', { ... }) で定義
  -- → 最後に vim.lsp.enable({ ... }) で自動起動
  ----------------------------------------------------------------------

  -- Lua（lua-language-server）
  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },    -- brew install lua-language-server
    filetypes = { 'lua' },
    root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = { checkThirdParty = false },
        hint = { enable = true },
      },
    },
  })

  -- TypeScript / JavaScript（typescript-language-server）
  vim.lsp.config('ts_ls', {
    name = 'ts_ls',
    cmd = { 'typescript-language-server', '--stdio' }, -- npm i -g typescript typescript-language-server
    filetypes = {
      'typescript', 'typescriptreact', 'typescript.tsx',
      'javascript', 'javascriptreact', 'javascript.jsx',
    },
    root_markers = {
      { 'tsconfig.json', 'jsconfig.json', 'package.json' },
      '.git',
    },
    settings = {
      typescript = { format = { semicolons = 'insert' } },
      javascript = { format = { semicolons = 'insert' } },
    },
    -- TS はフォーマットを他ツールに任せたい場合、ここで無効化してもOK
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })

  -- Python（pyright-langserver）
  vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' }, -- npm i -g pyright でも可
    filetypes = { 'python' },
    root_markers = { { 'pyproject.toml', 'setup.py', 'requirements.txt' }, '.git' },
    settings = {
      python = {
        analysis = {
          typeCheckingMode = 'basic',
          autoImportCompletions = true,
        },
      },
    },
  })

  ----------------------------------------------------------------------
  -- LSP起動
  ----------------------------------------------------------------------
  vim.lsp.enable({ 'lua_ls', 'ts_ls', 'pyright' })
end

return M

