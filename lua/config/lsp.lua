---@diagnostic disable: undefined-global
-- luacheck: globals vim

------------------------------------------------------------
-- LSP
--
-- cmd / filetypes / root_markers / settings は nvim-lspconfig 同梱の
-- lsp/<name>.lua をそのまま使う（Neovim が runtimepath から自動解決する）．
-- ここに書くのは，同梱設定では足りない分の上書きだけ．
------------------------------------------------------------

------------------------------------------------------------
-- MasonのbinをPATHに追加
-- Mason本体を読み込まずに，導入済みのLSP実行ファイルを利用する．
------------------------------------------------------------
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

------------------------------------------------------------
-- diagnostics
------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  update_in_insert = false,
  underline = true,
  severity_sort = true,
})

pcall(vim.lsp.log.set_level, "off")

------------------------------------------------------------
-- LspAttach
------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name == "copilot" then
      return
    end

    local bufnr = args.buf

    if client.name == "lua_ls" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
    end

    map("n", "gd", function()
      for _, attached_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if
          attached_client.name ~= "copilot"
          and attached_client:supports_method("textDocument/definition")
        then
          vim.lsp.buf.definition()
          return
        end
      end

      vim.notify(
        "No LSP server with textDocument/definition is attached to this buffer",
        vim.log.levels.WARN
      )
    end, "Goto Definition")

    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Prev Diagnostic")

    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next Diagnostic")
  end,
})

------------------------------------------------------------
-- 共通設定
------------------------------------------------------------
local capabilities = {}

do
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities()
  end
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

------------------------------------------------------------
-- 同梱設定への上書き
------------------------------------------------------------

-- Neovim設定では設定ディレクトリだけをworkspaceにする．
-- dotfiles全体や起動時のcwdを誤って走査することを防ぐ．
local nvim_config_dir = vim.fs.normalize(vim.fn.stdpath("config"))

local function lua_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    on_dir(nil)
    return
  end

  fname = vim.fs.normalize(fname)
  if fname == nvim_config_dir or fname:sub(1, #nvim_config_dir + 1) == nvim_config_dir .. "/" then
    on_dir(nvim_config_dir)
    return
  end

  local root = vim.fs.root(fname, {
    ".luarc.json",
    ".luarc.jsonc",
    ".git",
  })

  on_dir(root or vim.fs.dirname(fname))
end

vim.lsp.config("lua_ls", {
  root_dir = lua_root_dir,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        -- lazydev.nvimが必要なモジュールだけを動的に追加する．
        library = {},
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- 同梱設定のマーカーは .git だけなので，lint 設定ファイルも root として扱う．
vim.lsp.config("yamlls", {
  root_markers = {
    ".yamllint",
    ".yamllint.yaml",
    ".yamllint.yml",
    ".git",
  },
})

-- 同梱設定のマーカーに pyproject.toml を足す．
vim.lsp.config("taplo", {
  root_markers = {
    ".taplo.toml",
    "taplo.toml",
    "pyproject.toml",
    ".git",
  },
})

------------------------------------------------------------
-- 有効化
--
-- vim.lsp.enable() 自身が FileType を見てから起動するので，
-- ここで filetype ごとの振り分けを持つ必要はない．
------------------------------------------------------------
vim.lsp.enable({
  "pyright",
  "lua_ls",
  "yamlls",
  "taplo",
  "fortls",
})
