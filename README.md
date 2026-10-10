# settings_neovim

Linux 環境向けの Neovim 設定です．`lazy.nvim` でプラグインを管理し，LSP・補完・Copilot・ターミナル LLM 連携をまとめています．このリポジトリを `~/.config/nvim` としてクローンすれば，そのまま使えます．

## 1. 特徴

- `lazy.nvim` によるプラグイン管理（`lazy-lock.json` でバージョン固定）．
- Neovim 標準の `vim.lsp.config` / `vim.lsp.enable` による LSP 設定．サーバーは `mason.nvim` で導入．
- `nvim-cmp` + `LuaSnip` + GitHub Copilot による補完．
- `telescope.nvim`（検索），`neo-tree.nvim` / `oil.nvim`（ファイル操作），`flash.nvim`（ジャンプ）．
- `toggleterm.nvim` のフローティングターミナル．`:Claude` / `:Codex` で LLM CLI を起動．
- カラースキームは `tokyonight-moon`（背景透過）．

## 2. 動作要件

Neovim **0.11 以上**（`vim.lsp.config`，`vim.diagnostic.jump` を使用）と true color 対応の端末が必要です．

必須：`git`，C コンパイラと `make`（Tree-sitter，LuaSnip のビルド），`curl` または `wget`・`unzip`・`tar`（mason），`node` と `npm`（Copilot，pyright，yamlls）．

任意：`ripgrep`（Telescope の全文検索），`fd`（ファイル検索の高速化），`lazygit`，`zathura`（VimTeX の PDF 表示），`claude` / `codex`（LLM ターミナル）．無い場合は該当機能のみ使えません．

## 3. インストール

既存の設定があれば退避します．

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

クローンして起動します．

```bash
git clone https://github.com/g-hoshino/settings_neovim.git ~/.config/nvim
nvim
```

初回起動時に `lazy.nvim` とプラグインが自動で入り，Tree-sitter パーサーのビルドも走るため数分かかります．状況は `:Lazy` で確認し，完了後に再起動してください．

## 4. 初回セットアップ

### 4.1 LSP サーバー

必要な言語のサーバーを Mason で入れます（入れていないサーバーは単に起動しません）．

```vim
:MasonInstall pyright lua-language-server yaml-language-server taplo fortls
```

Python は `pyright`，Lua は `lua_ls`，YAML は `yamlls`，TOML は `taplo`，Fortran は `fortls` に対応しています．

### 4.2 Copilot

挿入モードに一度入ってから認証し，表示される URL とコードをブラウザで入力します．

```vim
:Copilot auth
```

使わない場合は `lua/plugins.lua` から `copilot.lua`，`copilot-cmp`，`CopilotChat.nvim` を削除してください．

### 4.3 Python provider

既定では `~/package/miniconda3/bin/python3` を Python provider として参照します．

```bash
~/package/miniconda3/bin/python3 -m pip install pynvim
```

パスが異なる場合は `lua/config/options.lua` の次の 2 行を自分の環境に合わせて書き換えます．Python を使わない場合は削除しても他の機能は動作します．

```lua
vim.env.PATH = home .. "/package/miniconda3/bin:" .. vim.env.PATH
vim.g.python3_host_prog = home .. "/package/miniconda3/bin/python3"
```

設定は `:checkhealth` で確認できます．

## 5. ディレクトリ構成

```text
~/.config/nvim/
├── init.lua                  # エントリポイント
├── lazy-lock.json            # プラグインのバージョン固定
├── lua/
│   ├── plugins.lua           # lazy.nvim のプラグイン仕様
│   └── config/
│       ├── lazy.lua          # lazy.nvim のブートストラップと設定
│       ├── options.lua       # 基本オプション，Python provider，OSC52
│       ├── providers.lua     # 不要な provider の無効化
│       ├── keymaps.lua       # グローバルキーマップ
│       ├── highlights.lua    # ハイライト上書き（透過など）
│       ├── llm.lua           # :Claude / :Codex ターミナル
│       ├── lsp.lua           # LSP サーバー設定
│       ├── cmp.lua           # 補完設定
│       ├── copilot.lua       # Copilot 設定
│       ├── lualine.lua       # ステータスライン設定
│       └── vimtex.lua        # VimTeX 設定
└── docs/
    └── llm-terminals.md      # LLM ターミナル連携の詳細
```

## 6. キーマップ

Leader は `<Space>`，local leader は `\` です．

> **注意**：`:` と `;` を入れ替えています．コマンドラインは `;` または `<C-j>` で開きます．不要なら `lua/config/keymaps.lua` の該当行を削除してください．

### 6.1 基本

| 操作 | キー |
|---|---|
| 保存 | `W` |
| 終了 | `Q` |
| 検索ハイライト解除 | `<Esc><Esc>` |
| ノーマルモードへ戻る（挿入モード） | `jj` |
| コマンドラインを開く | `<C-j>` |
| 前方検索 | `<C-f>` |
| 行頭へ移動 | `<Space>` |

### 6.2 ファイル・検索

| 操作 | キー |
|---|---|
| ファイル検索（Telescope） | `<leader>tf` |
| 全文検索（Telescope） | `<leader>tg` |
| Telescope 一覧 | `<C-t>` |
| Neo-tree のトグル | `<C-n>` |
| Oil でディレクトリを開く | `-` |
| Flash ジャンプ | `s` |

### 6.3 LSP

LSP が接続されたバッファでのみ有効です．

| 操作 | キー |
|---|---|
| 定義へ移動 | `gd` |
| 宣言へ移動 | `gD` |
| 実装へ移動 | `gi` |
| 参照一覧 | `gr` |
| hover 表示 | `K` |
| rename | `<leader>rn` |
| code action | `<leader>ca` |
| 前／次の診断へ | `[d` / `]d` |

### 6.4 補完

| 操作 | キー |
|---|---|
| 補完を開く | `<C-Space>` |
| 次／前の候補 | `<Tab>` / `<S-Tab>` |
| 確定 | `<CR>` |
| 補完を閉じる | `<C-e>` |

### 6.5 ターミナル・LLM

| 操作 | コマンド | キー |
|---|---|---|
| 通常のターミナル | `:ToggleTerm` | `<C-e>` |
| LLM を選択して起動 | `:LLM` | `<leader>aa` |
| Claude Code | `:Claude` | `<leader>ac` |
| Codex CLI | `:Codex` | `<leader>ax` |
| 直近の LLM を表示 | `:LLMStatus` | - |
| ターミナルモードを抜ける | - | `<Esc><Esc>` |
| LLM ターミナルを隠す | - | `<C-e>` |

詳細は [docs/llm-terminals.md](docs/llm-terminals.md) を参照してください．

### 6.6 その他

| 操作 | キー |
|---|---|
| Copilot Chat のトグル | `C` |
| 1 行 ↔ 複数行の変換（treesj） | `<Space>m` / `<Space>j` / `<Space>s` |
| lazygit の起動 | `:LazyGit` |

## 7. 更新

| 対象 | コマンド |
|---|---|
| プラグイン | `:Lazy update` |
| Tree-sitter パーサー | `:TSUpdate` |
| LSP サーバー | `:MasonUpdate` |

`:Lazy update` 後は `lazy-lock.json` が変化するので，問題なければコミットしてください．
