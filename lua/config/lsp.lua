---@diagnostic disable: undefined-global
-- luacheck: globals vim

------------------------------------------------------------
-- Mason の bin を PATH に追加
-- Mason で入れた pyright-langserver などを Neovim から見えるようにする
------------------------------------------------------------
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

------------------------------------------------------------
-- capabilities
------------------------------------------------------------
-- Neovim 側が make_client_capabilities() を必ずマージするため，
-- ここでは nvim-cmp が上乗せする補完 capabilities だけを渡す．
-- （default_capabilities() の引数は capabilities ではなくオプション表）
local capabilities = {}

do
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities()
  end
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
-- root_dir helper for Neovim 0.13
-- root marker が見つからない単独ファイルでも cwd を root にする
------------------------------------------------------------
local function root_dir_from(markers)
  return function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)

    local root = nil
    if fname ~= "" then
      root = vim.fs.root(fname, markers)
    end

    on_dir(root or vim.fn.getcwd())
  end
end

------------------------------------------------------------
-- LspAttach: LSP が buffer に attach した時だけ keymap を設定
-- Copilot は definition を提供しないため除外
------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client.name == "copilot" then
      return
    end

    local bufnr = args.buf

    if client.name == "lua_ls" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
    end

    map("n", "gd", function()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      for _, c in ipairs(clients) do
        if c.name ~= "copilot" and c:supports_method("textDocument/definition") then
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
vim.lsp.config("*", {
  capabilities = capabilities,
})

------------------------------------------------------------
-- pyright: Python
------------------------------------------------------------
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },

  root_dir = root_dir_from({
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }),

  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

------------------------------------------------------------
-- lua_ls: Lua
------------------------------------------------------------
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },

  root_dir = root_dir_from({
    ".luarc.json",
    ".luarc.jsonc",
    ".git",
  }),

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath("config"),
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

------------------------------------------------------------
-- yamlls: YAML
------------------------------------------------------------
vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },

  root_dir = root_dir_from({
    ".yamllint",
    ".yamllint.yaml",
    ".yamllint.yml",
    ".git",
  }),

  settings = {
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
    yaml = {
      format = {
        enable = true,
      },
    },
  },
})

------------------------------------------------------------
-- taplo: TOML
------------------------------------------------------------
vim.lsp.config("taplo", {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },

  root_dir = root_dir_from({
    ".taplo.toml",
    "taplo.toml",
    "pyproject.toml",
    ".git",
  }),
})

------------------------------------------------------------
-- fortls: Fortran
------------------------------------------------------------
vim.lsp.config("fortls", {
  cmd = {
    "fortls",
    "--notify_init",
    "--hover_signature",
    "--hover_language=fortran",
    "--use_signature_help",
  },

  filetypes = { "fortran" },

  root_dir = root_dir_from({
    ".fortls",
    ".fortlsrc",
    ".fortls.json",
    "fpm.toml",
    "CMakeLists.txt",
    "Makefile",
    ".git",
  }),
})

------------------------------------------------------------
-- LSP enable
-- まずは必要最小限だけ有効化
------------------------------------------------------------
vim.lsp.enable({
  "pyright",
  "lua_ls",
  "yamlls",
  "taplo",
  "fortls",
})
