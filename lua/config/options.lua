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

-- SSH先でもローカル端末のclipboardを使用
if vim.env.SSH_TTY then
  vim.g.clipboard = "osc52"
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
