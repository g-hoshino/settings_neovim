-- クリップボード／履歴
local opt = vim.opt
opt.clipboard      = "unnamedplus"    -- システムクリップボード共有
opt.viminfo        = "'20,\"10000"    -- 履歴／レジスタ保存
-- require("config.clipboard")  -- ファイル名に合わせて
vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}
