------------------------------------------------------------
-- キーマッピング
--
-- leader は <Space>（config/lazy.lua で設定）．
-- <Space> 単体にマッピングを置くと，leader 系マッピングとの曖昧判定で
-- timeoutlen（300ms）ぶん待たされるため，<Space> 単体は空けておく．
------------------------------------------------------------
local map = vim.keymap.set

-- 検索ハイライト解除（+ 画面再描画）
-- 以前は <Esc><Esc> だったが，ノーマルモードでの単発 <Esc> が
-- timeoutlen ぶん待たされるため <C-l> へ移動した．
map("n", "<C-l>", "<cmd>nohlsearch<CR><C-l>", { silent = true, desc = "検索ハイライト解除" })

-- 挿入モードで jj でノーマルモード
map("i", "jj", "<ESC>", { silent = true })

-- <C-j> でコマンドラインを開く（; と同じ役割）
map("n", "<C-j>", ":", { noremap = true })

-- Ctrl+n で Neo-tree を左にトグル表示
map("n", "<C-n>", ":Neotree toggle left<CR>")

-- Ctrl+f で前方検索（/）
map("n", "<C-f>", "/", { desc = "前方検索" })

-- コロンとセミコロンを入れ替え（挿入／ノーマル両方）
map("i", ";", ":")
map("i", ":", ";")
map("n", ";", ":")
map("n", ":", ";")

-- W で保存, Q で終了
map("n", "W", ":w<CR>", { desc = "保存" })
map("n", "Q", ":q<CR>", { desc = "終了" })
