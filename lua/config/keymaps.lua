------------------------------------------------------------
-- キーマッピング
------------------------------------------------------------
local map = vim.keymap.set

-- ESC 2回で検索ハイライト解除
map("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>")

-- 挿入モードで jj でノーマルモード
map("i", "jj", "<ESC>", { silent = true })

-- ノーマルモードで Space で行頭へ移動（^）
map("n", "<Space>", "^", { noremap = true, silent = true })

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
