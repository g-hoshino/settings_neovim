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

  should_attach = function()
    return true
  end,

  server_opts_overrides = {
    settings = {
      advanced = {
        inlineSuggestDelayMs = 100,
        networkTimeoutMs = 300,
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
