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
vim.g.maplocalleader = "\\"

local plugins = require("plugins")

-- 現行 nvim-treesitter は別organizationへ移行し，parser registryを使用する．
-- 遅延ロードには対応しないため，既存specを起動前に直接上書きする．
for _, spec in ipairs(plugins) do
  if type(spec) == "table" and spec[1] == "nvim-treesitter/nvim-treesitter" then
    spec[1] = "neovim-treesitter/nvim-treesitter"
    spec.branch = "main"
    spec.lazy = false
    spec.event = nil
    spec.cmd = nil
    spec.build = ":TSUpdate"
    spec.dependencies = {
      "neovim-treesitter/treesitter-parser-registry",
    }

    spec.config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then
        vim.notify("nvim-treesitter could not be loaded", vim.log.levels.ERROR)
        return
      end

      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("StartTreesitterForFiletypes", { clear = true }),
        pattern = {
          "lua",
          "vim",
          "vimdoc",
          "python",
          "bash",
          "json",
          "yaml",
          "markdown",
          "mdx",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Markdown の indent は不安定になりやすいので無効化．
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("DisableMarkdownTreesitterIndent", { clear = true }),
        pattern = {
          "markdown",
          "mdx",
        },
        callback = function(args)
          vim.bo[args.buf].indentexpr = ""
        end,
      })
    end

    break
  end
end

-- VimTeXの設定値はfiletype plugin読み込み前に定義する必要があるため，
-- plugins.luaの既存initをmacOS対応設定へ置き換える．
for _, spec in ipairs(plugins) do
  if type(spec) == "table" and spec[1] == "lervag/vimtex" then
    spec.init = function()
      require("config.vimtex").setup()
    end
    break
  end
end

require("lazy").setup(plugins, {
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
