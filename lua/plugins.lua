local function cfg(name)
  return function()
    require(name)
  end
end

return {

  ------------------------------------------------------------
  -- Git UI: lazygit を Neovim から開く
  ------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  ------------------------------------------------------------
  -- GitHub Copilot: AI 補完本体
  -- 重いので InsertEnter まで読み込まない
  ------------------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = cfg("config.copilot"),
  },

  ------------------------------------------------------------
  -- Copilot completion source for nvim-cmp
  -- Copilot と nvim-cmp の橋渡し
  ------------------------------------------------------------
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local ok, copilot_cmp = pcall(require, "copilot_cmp")
      if not ok then
        return
      end

      copilot_cmp.setup({
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        },
      })
    end,
  },

  ------------------------------------------------------------
  -- CopilotChat: Copilot とのチャット UI
  -- :CopilotChat を実行したときだけ読み込む
  ------------------------------------------------------------
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = "CopilotChat",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      window = {
        layout = "vertical",
        width = 0.40,
      },
      auto_insert_mode = true,
    },
    config = function(_, opts)
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      require("CopilotChat").setup(opts)
    end,
    keys = {
      {
        "C",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "CopilotChat: Toggle",
        mode = { "n" },
      },
    },
  },

  ------------------------------------------------------------
  -- nvim-cmp: 補完エンジン
  -- InsertEnter まで読み込まない
  ------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind-nvim",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = cfg("config.cmp"),
  },

  ------------------------------------------------------------
  -- LuaSnip: snippet engine
  -- 補完開始時まで読み込まない
  ------------------------------------------------------------
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    config = function()
      local ok, loader = pcall(require, "luasnip.loaders.from_vscode")
      if not ok then
        return
      end
      loader.lazy_load()
    end,
  },

  ------------------------------------------------------------
  -- cmp-cmdline: コマンドライン補完
  ------------------------------------------------------------
  {
    "hrsh7th/cmp-cmdline",
    event = "CmdlineEnter",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },

  ------------------------------------------------------------
  -- Mason: LSP / formatter / linter の管理 UI
  -- 起動時には読み込まず、:Mason 実行時のみ読み込む
  -- :MasonUpdate は手動で実行する
  ------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cmd = {
      "Mason",
      "MasonUpdate",
      "MasonLog",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
    },
    opts = {},
  },

  ------------------------------------------------------------
  -- mason-lspconfig: Mason と nvim-lspconfig の連携
  -- ファイルを開く直前に読み込む
  ------------------------------------------------------------
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },

  ------------------------------------------------------------
  -- nvim-lspconfig: LSP 設定本体
  -- Python / Lua / YAML / Fortran などの LSP を設定
  ------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = cfg("config.lsp"),
  },

  ------------------------------------------------------------
  -- fidget.nvim: LSP の進捗表示
  -- LSP attach 後に読み込む
  ------------------------------------------------------------
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },

  ------------------------------------------------------------
  -- noice.nvim: command line / LSP hover / notify UI の拡張
  -- やや重いので VeryLazy で読み込む
  ------------------------------------------------------------
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          stages = "fade_in_slide_out",
          timeout = 2000,
        },
      },
    },
    config = function()
      local ok, noice = pcall(require, "noice")
      if not ok then
        return
      end

      noice.setup({
        lsp = {
          hover = { enabled = true },
          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              trigger = true,
              luasnip = true,
            },
          },
          progress = { enabled = true },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
        views = {
          cmdline_popup = {
            position = {
              row = 10,
              col = "50%",
            },
          },
        },
        routes = {
          {
            filter = {
              event = "notify",
              find = "deprecated",
            },
            opts = {
              skip = true,
            },
          },
        },
      })
    end,
  },

  ------------------------------------------------------------
  -- lualine.nvim: ステータスライン
  -- UI 系なので VeryLazy で読み込む
  ------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      icons_enabled = true,
      theme = "auto",
    },
    config = cfg("config.lualine"),
  },

  ------------------------------------------------------------
  -- telescope.nvim: ファイル検索 / grep UI
  -- コマンドまたはキー入力時だけ読み込む
  ------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      {
        "<leader>tf",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find files",
      },
      {
        "<leader>tg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<C-t>",
        "<cmd>Telescope<CR>",
        mode = "n",
        desc = "Open Telescope",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  ------------------------------------------------------------
  -- neo-tree.nvim: ファイルツリー
  -- :Neotree 実行時だけ読み込む
  ------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        use_libuv_file_watcher = false,
        scan_mode = "shallow",
        async_directory_scan = "always",
        bind_to_cwd = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<C-k>"] = "navigate_up",
            ["<C-j>"] = "open",
          },
        },
      },
    },
  },

  ------------------------------------------------------------
  -- oil.nvim: ディレクトリをバッファとして編集する file manager
  -- キーまたは :Oil 実行時のみ読み込む
  ------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["<CR>"] = "actions.none",
        ["<C-j>"] = "actions.select",
      },
    },
    keys = {
      {
        "-",
        "<cmd>Oil<CR>",
        desc = "Open Oil file manager",
      },
    },
  },

  ------------------------------------------------------------
  -- nvim-treesitter: 構文解析 / 高精度ハイライト
  --
  -- Neovim 0.13 では Markdown の Treesitter highlighter で
  -- "attempt to call method 'range' (a nil value)" が出る場合があるため,
  -- Markdown では Treesitter を完全に起動しない.
  --
  -- Markdown は Vim 標準 syntax highlight を使う.
  ------------------------------------------------------------
  ---
  ------------------------------------------------------------
  -- nvim-treesitter: 構文解析 / 高精度ハイライト
  --
  -- Neovim 0.13 + nvim-treesitter main branch 用.
  -- Markdown も Treesitter highlight を使う.
  ------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then
        return
      end

      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local parsers = {
        "lua",
        "vim",
        "vimdoc",
        "python",
        "bash",
        "json",
        "yaml",
        "regex",
        "markdown",
        "markdown_inline",
      }

      pcall(ts.install, parsers)

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

      -- Markdown の indent は不安定になりやすいので無効化.
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
    end,
  },

  ------------------------------------------------------------
  -- indent-blankline.nvim: インデントガイド表示
  -- Markdown では Treesitter scope を使わせない
  ------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok_ibl, ibl = pcall(require, "ibl")
      if not ok_ibl then
        return
      end

      local ok_hooks, hooks = pcall(require, "ibl.hooks")
      if not ok_hooks then
        return
      end

      local rainbow = {
        "RainbowRed",
        "RainbowBlue",
        "RainbowGreen",
        "RainbowOrange",
        "RainbowYellow",
        "RainbowViolet",
        "RainbowCyan",
      }

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#f7768e" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#e0af68" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#7aa2f7" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#ff9e64" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#9ece6a" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#bb9af7" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#7dcfff" })
        vim.api.nvim_set_hl(0, "IblIndent", { link = "LineNr" })
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#c0caf5", bold = true, nocombine = true })
      end)

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      ibl.setup({
        enabled = true,

        exclude = {
          filetypes = {
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "oil",
            "toggleterm",
            "terminal",
            "prompt",
            "noice",
            "notify",
            "markdown",
            "markdown.mdx",
            "mdx",
          },
        },

        indent = {
          char = "│",
          highlight = rainbow,
        },

        scope = {
          enabled = true,
          show_exact_scope = true,
          highlight = { "IblScope" },
          char = "┃",
          show_start = false,
          show_end = false,
        },

        whitespace = {
          remove_blankline_trail = true,
        },
      })
    end,
  },

  ------------------------------------------------------------
  -- nvim-autopairs: 自動括弧補完
  -- InsertEnter まで読み込まない
  ------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  ------------------------------------------------------------
  -- toggleterm.nvim: ターミナル管理
  -- :ToggleTerm / Ctrl-e 実行時だけ読み込む
  ------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = {
      "ToggleTerm",
      "TermExec",
    },
    keys = {
      {
        "<C-e>",
        "<cmd>ToggleTerm<CR>",
        mode = { "n", "t" },
      },
    },
    opts = {
      direction = "float",
      float_opts = {
        border = {
          { "╭", "ToggleTermBorder" },
          { "─", "ToggleTermBorder" },
          { "╮", "ToggleTermBorder" },
          { "│", "ToggleTermBorder" },
          { "╯", "ToggleTermBorder" },
          { "─", "ToggleTermBorder" },
          { "╰", "ToggleTermBorder" },
          { "│", "ToggleTermBorder" },
        },
        width = function()
          return math.floor(vim.o.columns * 0.5)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
        row = function()
          local h = math.floor(vim.o.lines * 0.9)
          return math.floor((vim.o.lines - h) / 2)
        end,
        col = function()
          local w = math.floor(vim.o.columns * 0.5)
          return vim.o.columns - w - 5
        end,
      },
      shade_terminals = true,
      persist_size = true,
      persist_mode = true,
    },
  },

  ------------------------------------------------------------
  -- vimtex: LaTeX 編集支援
  -- tex / bib ファイルを開いた時だけ読み込む
  ------------------------------------------------------------
  {
    "lervag/vimtex",
    ft = {
      "tex",
      "plaintex",
      "bib",
    },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  ------------------------------------------------------------
  -- tokyonight.nvim: colorscheme
  -- colorscheme は起動時に必要なので lazy = false
  ------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      transparent = true,
      show_end_of_buffer = false,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          pcall(vim.api.nvim_set_hl, 0, "Comment", {
            fg = "#8FAFC2",
            ctermfg = "LightBlue",
          })
        end,
      })
    end,
  },

  ------------------------------------------------------------
  -- flash.nvim: 高速ジャンプ
  -- VeryLazy で読み込み、通常ジャンプのみ有効化
  ------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },

      -- Treesitter search は Neovim 0.13 の Markdown 問題が安定するまで無効化
      -- {
      --   "S",
      --   mode = { "n", "x", "o" },
      --   function()
      --     require("flash").treesitter()
      --   end,
      --   desc = "Flash Treesitter",
      -- },
      -- {
      --   "R",
      --   mode = { "o", "x" },
      --   function()
      --     require("flash").treesitter_search()
      --   end,
      --   desc = "Treesitter Search",
      -- },
    },
  },
}
