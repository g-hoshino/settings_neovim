local ok, copilot = pcall(require, "copilot")
if not ok then return end

copilot.setup({
  panel = { enabled = false },        -- パネルは重いので無効のまま
  suggestion = {
    enabled = true,
    auto_trigger = false,             -- 入力なしでは提案を出さない（従来どおり）
    debounce = 120,
    keymap = { accept = false },      -- <Tab> 確定は cmp 側で
  },

  -- すべてのファイルタイプで許可（個別で止めない）
  filetypes = { ["*"] = true },

  -- 常にアタッチ（自動停止しない）
  should_attach = function(_) return true end,

  server_opts_overrides = {
    settings = {
      advanced = {
        inlineSuggestDelayMs = 100,
        networkTimeoutMs = 300,
      },
    },
  },

  filetypes = {
    help = false,
    text = false,
    yaml = false,
    json = false,
    toml = false,
    dat = false,
  },
})

pcall(function()
  require("copilot_cmp").setup()
end)

-- cmp メニューが開いたときは Copilot ゴーストを隠す（誤確定防止）
pcall(function()
  local cmp = require("cmp")
  local suggestion = require("copilot.suggestion")
  cmp.event:on("menu_opened", function()
    if suggestion.is_visible() then suggestion.dismiss() end
  end)
end)
