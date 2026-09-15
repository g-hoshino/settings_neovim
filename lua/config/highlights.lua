------------------------------------------------------------
-- ハイライト：コメント色／行番号／透明背景
------------------------------------------------------------

local comment_fg = "#8FAFC2"

local function set_my_hl()
  vim.api.nvim_set_hl(0, "Comment", {
    fg = comment_fg,
    ctermfg = "LightBlue",
    italic = false,
    nocombine = true,
  })

  vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = comment_fg,
    bold = true,
  })

  for _, group in ipairs({ "LineNr", "LineNrAbove", "LineNrBelow" }) do
    vim.api.nvim_set_hl(0, group, { fg = comment_fg })
  end

  vim.api.nvim_set_hl(0, "AicliBorder", { link = "Normal" })
  vim.api.nvim_set_hl(0, "AicliTitle", { link = "Normal" })
end

local function set_transparent_highlights()
  local groups = {
    "Normal",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeEndOfBuffer",
    "NeoTreeWinSeparator",
    "NeoTreeFloatBorder",
    "NeoTreeFloatTitle",
  }

  for _, group in ipairs(groups) do
    pcall(vim.api.nvim_set_hl, 0, group, { bg = "none" })
  end

  pcall(function()
    local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
    vim.api.nvim_set_hl(0, "Folded", comment)
  end)
end

local function set_copilot_hl()
  for _, group in ipairs({ "CopilotSuggestion", "CmpGhostText" }) do
    pcall(vim.api.nvim_set_hl, 0, group, { link = "Comment" })
  end
end

local function apply_highlights()
  set_my_hl()
  set_transparent_highlights()
  set_copilot_hl()
end

apply_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserHighlightOverrides", { clear = true }),
  callback = apply_highlights,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("UserCopilotHighlightOverrides", { clear = true }),
  pattern = { "CopilotLoaded", "CopilotAttach" },
  callback = set_copilot_hl,
})
