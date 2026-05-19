# Neovim Setup

この README では, Linux 環境で Neovim を使うための最小構成をまとめます.
Python provider は miniconda 環境を使い, Python 関連のライブラリも miniconda で管理します.

## 1. 方針

この設定では, 次の構成を使います.

- Neovim 本体.
- lazy.nvim によるプラグイン管理.
- Treesitter による構文解析.
- Telescope によるファイル検索.
- nvim-lspconfig による LSP 設定.
- cmp.nvim による補完.
- miniconda による Python provider 管理.

Neovim の Python provider には, miniconda の Python を明示的に指定します.

## 2. miniconda 環境の作成

まず, Neovim 用の conda 環境を作成します.

```bash
conda create -n nvim python=3.11 -y
conda activate nvim
```

Neovim の Python provider に必要なライブラリをインストールします.

```bash
conda install -c conda-forge pynvim nodejs ripgrep fd-find -y
```

Python 開発でよく使うライブラリも, 必要に応じて同じ環境に入れます.

```bash
conda install -c conda-forge numpy scipy matplotlib pandas ipython jupyter -y
```

LSP 用の Python パッケージを入れます.

```bash
conda install -c conda-forge python-lsp-server ruff black isort -y
```

## 3. ディレクトリ構成

Neovim の設定ファイルは, 次の構成にします.

```text
~/.config/nvim/
├── init.lua
└── lua/
    ├── options.lua
    ├── keymaps.lua
    ├── plugins.lua
    └── lsp.lua
```

## 4. init.lua

`~/.config/nvim/init.lua` を作成します.

```lua
require("options")
require("keymaps")
require("plugins")
require("lsp")
```

## 5. options.lua

`~/.config/nvim/lua/options.lua` を作成します.

```lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.clipboard = "unnamedplus"

opt.undofile = true
opt.swapfile = false
opt.backup = false

vim.g.python3_host_prog = os.getenv("HOME") .. "/package/miniconda3/envs/nvim/bin/python"
```

miniconda の場所が異なる場合は, 最後の行を自分の環境に合わせて変更します.

例.

```lua
vim.g.python3_host_prog = os.getenv("HOME") .. "/miniconda3/envs/nvim/bin/python"
```

## 6. keymaps.lua

`~/.config/nvim/lua/keymaps.lua` を作成します.

```lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

keymap("n", "<leader>e", ":Ex<CR>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)

keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "K", vim.lsp.buf.hover, opts)
keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
keymap("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, opts)
```

## 7. plugins.lua

`~/.config/nvim/lua/plugins.lua` を作成します.

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-lua/plenary.nvim",
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "python",
          "bash",
          "markdown",
          "vim",
          "vimdoc",
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
})
```

## 8. lsp.lua

`~/.config/nvim/lua/lsp.lua` を作成します.

```lua
local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

lspconfig.pylsp.setup({
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = false,
        },
        pyflakes = {
          enabled = true,
        },
        ruff = {
          enabled = true,
        },
        black = {
          enabled = true,
        },
        isort = {
          enabled = true,
        },
      },
    },
  },
})

local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
})
```

## 9. 起動確認

Neovim を起動します.

```bash
nvim
```

Python provider が正しく設定されているか確認します.

```vim
:checkhealth provider
```

Python provider の欄に, miniconda 環境の Python が表示されていれば問題ありません.

LSP の状態は, Python ファイルを開いた状態で次を実行して確認します.

```vim
:LspInfo
```

`pylsp` が attached になっていれば, Python LSP が有効です.

## 10. よく使う操作

| 操作 | キー |
|---|---|
| 保存 | `<leader>w` |
| 終了 | `<leader>q` |
| ファイル一覧 | `<leader>ff` |
| 文字列検索 | `<leader>fg` |
| buffer 一覧 | `<leader>fb` |
| 定義へ移動 | `gd` |
| 参照一覧 | `gr` |
| hover 表示 | `K` |
| rename | `<leader>rn` |
| code action | `<leader>ca` |
| format | `<leader>f` |
| コメント切り替え | `gcc` |

## 11. トラブルシュート

### Python provider が見つからない場合

`pynvim` が入っているか確認します.

```bash
conda activate nvim
python -c "import pynvim; print(pynvim.__version__)"
```

エラーが出る場合は, 再度インストールします.

```bash
conda install -c conda-forge pynvim -y
```

### live_grep が動かない場合

`ripgrep` が入っているか確認します.

```bash
rg --version
```

入っていない場合は, conda でインストールします.

```bash
conda install -c conda-forge ripgrep -y
```

### find_files が遅い場合

`fd` が入っているか確認します.

```bash
fd --version
```

入っていない場合は, conda でインストールします.

```bash
conda install -c conda-forge fd-find -y
```

### LSP が起動しない場合

Python LSP が入っているか確認します.

```bash
conda activate nvim
pylsp --version
```

入っていない場合は, conda でインストールします.

```bash
conda install -c conda-forge python-lsp-server -y
```

## 12. 最小更新手順

設定を更新した後は, Neovim 内で次を実行します.

```vim
:Lazy sync
```

Treesitter を更新する場合は, 次を実行します.

```vim
:TSUpdate
```

LSP の挙動がおかしい場合は, Neovim を再起動してから確認します.

```vim
:LspInfo
```

## 13. まとめ

この構成では, Neovim 本体の設定を Lua で管理し, Python provider と Python 開発用ライブラリを miniconda に集約します.
これにより, Python 環境の依存関係を system Python から分離でき, HPC 環境や研究用 Linux 環境でも再現しやすい設定になります.
