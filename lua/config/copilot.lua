local ok, copilot = pcall(require, "copilot")
if not ok then
  return
end

copilot.setup({
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = false,
    debounce = 120,
    keymap = { accept = false },
  },

  -- 既定の should_attach はバッファ種別やサイズを見て弾く．
  -- 常に true を返すとその判定を潰してしまうので，
  -- 大きいファイルと無名バッファは自前で除外する．
  should_attach = function(bufnr)
    if vim.b[bufnr].bigfile then
      return false
    end
    if vim.api.nvim_buf_get_name(bufnr) == "" then
      return false
    end
    if vim.api.nvim_buf_line_count(bufnr) > 40000 then
      return false
    end
    return true
  end,

  server_opts_overrides = {
    settings = {
      advanced = {
        inlineSuggestDelayMs = 100,
        -- 300ms は短すぎて，回線が遅いときに提案が黙って落ちる．
        networkTimeoutMs = 3000,
      },
    },
  },

  filetypes = {
    ["*"] = true,
    help = false,
    text = false,
    yaml = false,
    json = false,
    toml = false,
    dat = false,
  },
})

-- cmp メニューが開いたときは Copilot のゴースト表示を隠す．
pcall(function()
  local cmp = require("cmp")
  local suggestion = require("copilot.suggestion")
  cmp.event:on("menu_opened", function()
    if suggestion.is_visible() then
      suggestion.dismiss()
    end
  end)
end)
