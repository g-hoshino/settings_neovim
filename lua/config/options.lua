local opt = vim.opt
local home = os.getenv("HOME")

------------------------------------------------------------
-- 環境設定：Conda Python / Lua モジュールローダー
------------------------------------------------------------

-- Conda の Python を PATH に追加（GUI / 非 login シェルでも有効）
vim.env.PATH = home .. "/package/miniconda3/bin:" .. vim.env.PATH

-- Neovim の Python3 プロバイダに Miniconda の Python を使う
vim.g.python3_host_prog = home .. "/package/miniconda3/bin/python3"

------------------------------------------------------------
-- 基本オプション
------------------------------------------------------------

-- 文字コード／カラー
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencodings = { "utf-8", "ucs-bom", "default", "latin1" }
opt.termguicolors = true

-- 表示
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 10

-- 編集挙動
opt.autoread = true
opt.showcmd = true
opt.smartindent = true
opt.showmatch = true
opt.laststatus = 3 -- lualine の globalstatus = true と対応させる
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeout = true
opt.ttimeoutlen = 30

-- 折りたたみ
-- indent は編集のたびに全行の fold level を再計算するため，
-- 大きいファイルでは config.bigfile 側で manual に切り替える．
opt.foldmethod = "indent"
opt.foldenable = true
opt.foldlevel = 99

-- タブ／インデント
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.wrapscan = true
opt.hlsearch = true

-- クリップボード／履歴
opt.clipboard = "unnamedplus"
opt.shada = "'20,\"1000"

-- OSC52 clipboard
-- copy は端末へ書き込むだけなので OSC52 を使う．
-- paste は OSC52 だと端末応答を vim.wait() で同期的に待ち，応答しない端末では
-- 貼り付けのたびに最大 1 秒ブロックするため，直前の yank レジスタを返す．
do
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    local function paste_from_unnamed()
      return vim.split(vim.fn.getreg('"'), "\n")
    end

    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = paste_from_unnamed,
        ["*"] = paste_from_unnamed,
      },
    }
  end
end

------------------------------------------------------------
-- パフォーマンス系オプション
------------------------------------------------------------

opt.writebackup = false
opt.backup = false
opt.swapfile = false

-- undo 履歴を保存したいなら true にする
opt.undofile = false

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.updatetime = 300
opt.fsync = false
