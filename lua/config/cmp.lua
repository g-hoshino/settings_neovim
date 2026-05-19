-- cmp / luasnip を安全に読み込み
local ok_cmp, cmp = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")
if not (ok_cmp and ok_snip) then
  return
end

-- LuaSnip の基本設定
-- VSCode snippet の lazy_load は plugins.lua 側で一度だけ実行する
luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = false,
})

cmp.setup({
  completion = {
    keyword_length = 2,
    autocomplete = {
      cmp.TriggerEvent.TextChanged,
    },
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({
      select = false,
      behavior = cmp.ConfirmBehavior.Insert,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),

  sources = cmp.config.sources({
    { name = "copilot",  group_index = 1, priority = 100, keyword_length = 0 },
    { name = "nvim_lsp", group_index = 2, priority = 90 },
    { name = "path",     group_index = 2, priority = 80 },
    { name = "luasnip",  group_index = 3, priority = 70 },
    { name = "buffer",   group_index = 4, priority = 50, keyword_length = 3 },
  }),

  experimental = {
    ghost_text = false,
  },
})
