local fn = vim.fn
local uv = vim.uv or vim.loop

local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  local result = fn.system({
    "git",
    "clone",
    "--branch=stable",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. result)
  end
end

vim.opt.rtp:prepend(lazypath)

-- leader は lazy.nvim setup より前に設定する
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("lazy").setup("plugins", {
  rocks = {
    enabled = false,
  },

  change_detection = {
    enabled = false,
    notify = false,
  },

  -- GitHub 接続が安定したなら 2 or 4 にしてよい
  -- 不安定なら 1 に戻す
  concurrency = 2,

  git = {
    timeout = 800,
    url_format = "https://github.com/%s.git",

    -- partial clone 由来の promisor remote 問題を避ける
    filter = false,
  },

  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
        "rplugin",

        -- netrw を完全に無効化したい場合のみ残す
        -- neo-tree / oil.nvim を使うなら無効化してもよい
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
      },
    },
  },
})
