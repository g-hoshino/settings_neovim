local M = {}

local function app_exists(name)
  local home = vim.env.HOME or ""
  return vim.fn.isdirectory("/Applications/" .. name .. ".app") == 1
    or vim.fn.isdirectory(home .. "/Applications/" .. name .. ".app") == 1
end

local function set_highlights()
  local links = {
    texArg = "String",
    texCmd = "Function",
    texCmdClass = "Type",
    texCmdEnv = "Keyword",
    texCmdGreek = "Constant",
    texCmdPackage = "Include",
    texCmdType = "Type",
    texComment = "Comment",
    texDelim = "Delimiter",
    texEnvArgName = "Type",
    texFileArg = "String",
    texMathCmd = "Function",
    texMathDelim = "Delimiter",
    texMathOper = "Operator",
    texMathSymbol = "Special",
    texMathZone = "Constant",
    texOpt = "Identifier",
    texPartArgTitle = "Title",
    texRefArg = "Identifier",
    texSpecialChar = "SpecialChar",
    texTitleArg = "Title",
  }

  for group, target in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = target })
  end
end

function M.setup()
  vim.g.vimtex_compiler_method = "latexmk"
  vim.g.vimtex_quickfix_mode = 0
  vim.g.vimtex_syntax_enabled = 1

  -- Concealを使わない場合のVimTeX syntaxを詳細化する．
  vim.g.vimtex_syntax_conceal_disable = 1

  if vim.fn.has("macunix") == 1 then
    if app_exists("Skim") then
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    else
      -- Skim未導入時もZathuraエラーを出さず，PreviewでPDFを開く．
      -- PreviewではSyncTeXによるforward searchは利用できない．
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "open"
      vim.g.vimtex_view_general_options = "-a Preview"
    end
  else
    vim.g.vimtex_view_method = "zathura"
  end

  vim.cmd("syntax enable")
  set_highlights()

  local group = vim.api.nvim_create_augroup("VimtexLocalConfiguration", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_highlights,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "tex", "plaintex" },
    callback = function(args)
      -- LaTeXではVimTeXのsyntaxを優先する．Treesitter LaTeXを同時に
      -- 起動するとVimTeX側の詳細なsyntax highlightingが無効になる．
      pcall(vim.treesitter.stop, args.buf)
      vim.wo.conceallevel = 0
      vim.cmd("syntax enable")
      set_highlights()
    end,
  })
end

return M
