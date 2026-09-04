local function load_config(name)
  return function()
    require(name)
  end
end

return {
  -- ==========================================================================

  -- UI・外観

  -- ==========================================================================

  -- Tokyo Night Moonカラースキームを適用する．
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      on_highlights = function(highlights)
        highlights.Comment = {
          fg = "#8FAFC2",
          ctermfg = "LightBlue",
        }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },

  -- コマンドライン，通知，LSPドキュメントの表示UIを拡張する．
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim", -- ポップアップなどのUI部品．
      {
        -- vim.notifyの通知を画面右上などへ表示する．
        "rcarriga/nvim-notify",
        opts = {
          stages = "fade_in_slide_out",
          timeout = 2000,
        },
      },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
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
          opts = { skip = true },
        },
      },
    },
  },

  -- モード，Git，LSPなどの状態を画面下部に表示するステータスライン．
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- ファイル種別アイコン．
    config = load_config("config.lualine"),
  },

  -- インデント位置と現在の構文スコープを縦線で可視化する．
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local hooks = require("ibl.hooks")
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
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#c0caf5", bold = true, nocombine = true })
      end)

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      require("ibl").setup({
        exclude = {
          filetypes = {
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "oil",
            "toggleterm",
            "noice",
            "notify",
            "markdown",
            "mdx",
          },
        },
        indent = {
          char = "│",
          highlight = rainbow,
        },
        scope = {
          show_exact_scope = true,
          highlight = { "IblScope" },
          char = "┃",
          show_start = false,
          show_end = false,
        },
      })
    end,
  },

  -- ==========================================================================

  -- 検索・移動・ファイル操作

  -- ==========================================================================

  -- ファイル検索，全文検索，バッファ検索などを行うファジーファインダー．
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" }, -- Telescopeが使用するLuaユーティリティ集．
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
        desc = "Open Telescope",
      },
    },
  },

  -- ディレクトリ構造を左側のツリーとして表示・操作する．
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim", -- ファイル走査などの補助機能．
      "nvim-tree/nvim-web-devicons", -- ファイル種別アイコン．
      "MunifTanjim/nui.nvim", -- ツリーUIの構築．
    },
    opts = {
      filesystem = {
        async_directory_scan = "always",
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
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

  -- ディレクトリを通常のバッファとして開き，ファイル操作を編集操作として行う．
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- ファイル種別アイコン．
    opts = {
      default_file_explorer = false,
      view_options = { show_hidden = true },
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

  -- 画面内の候補文字へ少ないキー入力で高速にジャンプする．
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
        "<C-s>",
        mode = "c",
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- ==========================================================================

  -- 構文解析・編集支援

  -- ==========================================================================

  -- Tree-sitterパーサーを管理し，構文解析に基づくハイライトを有効化する．
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.install({
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
      })

      vim.treesitter.language.register("markdown", "mdx")

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
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
    end,
  },

  -- Tree-sitterの構文木を使い，リストや引数を1行・複数行へ相互変換する．
  {
    "Wansmer/treesj",
    keys = { "<space>m", "<space>j", "<space>s" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- 括弧や引用符を入力したとき，対応する閉じ文字を自動挿入する．
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- ==========================================================================

  -- 補完・AI支援

  -- ==========================================================================

  -- GitHub Copilotの提案を取得する補完クライアント本体．
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = load_config("config.copilot"),
  },

  -- VS Code形式のスニペットを読み込み，展開する．
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Copilotの提案をnvim-cmpの候補として表示する連携プラグイン．
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup({
        formatters = {
          insert_text = require("copilot_cmp.format").remove_existing,
        },
      })
    end,
  },

  -- LSP，Copilot，バッファ，パスなどの候補を統合する補完エンジン．
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "zbirenbaum/copilot-cmp", -- Copilot補完ソース．
      "hrsh7th/cmp-nvim-lsp", -- LSP補完ソース．
      "hrsh7th/cmp-buffer", -- 開いているバッファ内の単語を補完．
      "hrsh7th/cmp-path", -- ファイルパスを補完．
      "onsails/lspkind-nvim", -- 補完候補に種類別アイコンを表示．
      "saadparwaiz1/cmp_luasnip", -- LuaSnipをnvim-cmpへ接続．
      "L3MON4D3/LuaSnip", -- スニペット展開エンジン．
    },
    config = load_config("config.cmp"),
  },

  -- `:`，`/`，`?`などのコマンドラインにnvim-cmp補完を提供する．
  {
    "hrsh7th/cmp-cmdline",
    event = "CmdlineEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
  },

  -- GitHub Copilot Chatを縦分割ウィンドウで利用する．
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = "CopilotChat",
    dependencies = { "nvim-lua/plenary.nvim" }, -- 非同期処理などに使用．
    opts = {
      auto_insert_mode = true,
      window = {
        layout = "vertical",
        width = 0.4,
      },
    },
    config = function(_, opts)
      vim.opt.splitright = true
      require("CopilotChat").setup(opts)
    end,
    keys = {
      {
        "C",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "CopilotChat: Toggle",
      },
    },
  },

  -- ==========================================================================

  -- LSP・開発ツール

  -- ==========================================================================

  -- LSP，formatter，linterなどの外部ツールをインストール・管理する．
  {
    "mason-org/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
    },
    opts = {},
  },

  -- Masonで導入したLSPとNeovim 0.12のLSP機能を接続する．
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim", -- 外部ツール管理．
      "neovim/nvim-lspconfig", -- 各LSPサーバーの標準設定集．
      "hrsh7th/cmp-nvim-lsp", -- LSPの補完能力をnvim-cmpへ渡す．
    },
    opts = {},
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      require("config.lsp")
    end,
  },

  -- ==========================================================================

  -- Git

  -- ==========================================================================

  -- lazygitをNeovim内から起動するGit操作用UI．
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" }, -- Luaユーティリティ集．
  },

  -- ==========================================================================

  -- ターミナル

  -- ==========================================================================

  -- Neovim内のターミナルをフローティングウィンドウとして開閉する．
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
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
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.5)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
        row = function()
          local height = math.floor(vim.o.lines * 0.9)
          return math.floor((vim.o.lines - height) / 2)
        end,
        col = function()
          local width = math.floor(vim.o.columns * 0.5)
          return vim.o.columns - width - 5
        end,
      },
    },
  },

  -- ==========================================================================

  -- LaTeX

  -- ==========================================================================

  -- LaTeX文書のコンパイル，PDF表示，エラー確認，補助編集を支援する．
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
