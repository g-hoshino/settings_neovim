------------------------------------------------------------
-- ハイライト：コメント色／行番号／透明背景
------------------------------------------------------------

local function set_my_hl()
  vim.api.nvim_set_hl(0, "Comment", {
    fg = "#8FAFC2",
    ctermfg = "LightBlue",
    italic = false,
    nocombine = true,
  })

  vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = "#8FAFC2",
    bold = true,
  })

  vim.api.nvim_set_hl(0, "LineNr", {
    fg = "#8FAFC2",
  })

  vim.api.nvim_set_hl(0, "LineNrAbove", {
    fg = "#8FAFC2",
  })

  vim.api.nvim_set_hl(0, "LineNrBelow", {
    fg = "#8FAFC2",
  })

  vim.api.nvim_set_hl(0, "FloatBorder", {
    fg = "#ff00ff",
    bg = "none",
  })

  vim.api.nvim_set_hl(0, "ToggleTermBorder", {
    fg = "#ff4dd0",
    bold = true,
  })
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
  pcall(vim.api.nvim_set_hl, 0, "CopilotSuggestion", {
    link = "Comment",
  })

  pcall(vim.api.nvim_set_hl, 0, "CmpGhostText", {
    link = "Comment",
  })
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
  pattern = {
    "CopilotLoaded",
    "CopilotAttach",
  },
  callback = set_copilot_hl,
})
