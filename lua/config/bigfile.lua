------------------------------------------------------------
-- 大きいファイルの保護
--
-- 一定サイズを超えるファイルでは，構文解析・補完・行単位の再描画など
-- 行数に比例して重くなる機能をバッファ単位で無効化する．
-- 判定結果は vim.b[bufnr].bigfile に入るので，
-- treesitter（plugins.lua）や Copilot（config.copilot）からも参照する．
------------------------------------------------------------

local M = {}

-- この値を超えたファイルを「大きいファイル」として扱う．
M.size_limit = 1024 * 1024 -- 1 MiB

---@param bufnr integer
---@return boolean
function M.is_bigfile(bufnr)
  return vim.b[bufnr].bigfile == true
end

local group = vim.api.nvim_create_augroup("UserBigFile", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
  group = group,
  callback = function(args)
    local ok, stat = pcall((vim.uv or vim.loop).fs_stat, args.match)
    if not ok or not stat or stat.size < M.size_limit then
      return
    end

    local bufnr = args.buf
    vim.b[bufnr].bigfile = true

    -- swap / undo の書き出しを止める．
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].undolevels = -1

    -- indent-blankline はバッファ単位で無効化できる．
    pcall(function()
      require("ibl").setup_buffer(bufnr, { enabled = false })
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(args)
    if not M.is_bigfile(args.buf) then
      return
    end

    -- ウィンドウ単位のオプションはバッファが窓に入ってから設定する．
    local winid = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(winid) ~= args.buf then
      return
    end

    vim.wo[winid].foldmethod = "manual"
    vim.wo[winid].cursorline = false
    vim.wo[winid].relativenumber = false
  end,
})

return M
