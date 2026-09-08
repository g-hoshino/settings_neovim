------------------------------------------------------------
-- 不要なリモートプラグイン無効化
------------------------------------------------------------
vim.g.loaded_node_provider = 0   -- Node リモートプラグイン不要なら
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- python3 リモートプラグインを使うプラグインは現在の構成には無い．
-- 無効化しておくと，必要になった瞬間に conda の python3 を spawn する
-- コスト（options.lua の python3_host_prog）が発生しなくなる．
-- python3 プロバイダが要るプラグインを入れたら，この行を消す．
vim.g.loaded_python3_provider = 0
