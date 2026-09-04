# settings_neovim

Linux 環境向けの Neovim 設定です．`lazy.nvim` でプラグインを管理し，LSP・補完・Copilot・ターミナル LLM 連携をまとめています．

このリポジトリを `~/.config/nvim` としてクローンすれば，そのまま使えます．

## 1. 特徴

- `lazy.nvim` によるプラグイン管理（`lazy-lock.json` でバージョン固定）．
- Neovim 標準の `vim.lsp.config` / `vim.lsp.enable` による LSP 設定．LSP サーバーは `mason.nvim` で導入．
- `nvim-cmp` + `LuaSnip` + GitHub Copilot による補完．
- `telescope.nvim`（検索），`neo-tree.nvim` / `oil.nvim`（ファイル操作），`flash.nvim`（ジャンプ）．
- `toggleterm.nvim` のフローティングターミナル．`:Claude` / `:Codex` で LLM CLI を同じ見た目で起動．
- カラースキームは `tokyonight-moon`（背景透過）．
- Python provider は Miniconda の Python を使用．

## 2. 動作要件

### 2.1 Neovim 本体

Neovim **0.11 以上**が必要です（`vim.lsp.config`，`vim.diagnostic.jump` を使用）．0.12 系で動作確認しています．

```bash
nvim --version
```

### 2.2 必須の外部コマンド

| コマンド | 用途 |
|---|---|
| `git` | lazy.nvim とプラグインの取得 |
| `cc` / `gcc` などの C コンパイラ，`make` | Tree-sitter パーサーと LuaSnip の `jsregexp` のビルド |
| `curl` または `wget`，`unzip`，`tar` | mason.nvim による LSP サーバーの取得 |
| `node`，`npm` | Copilot および一部の LSP サーバー（pyright，yamlls）の実行 |

### 2.3 推奨の外部コマンド

| コマンド | 用途 | 無い場合 |
|---|---|---|
| `ripgrep`（`rg`） | Telescope の `live_grep` | 全文検索が動作しない |
| `fd` | Telescope のファイル検索の高速化 | 検索が遅くなる |
| `lazygit` | `:LazyGit` | コマンドが使えない |
| `zathura` | VimTeX の PDF 表示 | LaTeX のプレビューが開かない |
| `claude` / `codex` | LLM ターミナル連携 | `:Claude` / `:Codex` が使えない |

### 2.4 フォント

アイコン表示に **Nerd Font** が必要です．端末エミュレータ側で Nerd Font を設定してください．設定しない場合，ステータスラインやファイルツリーのアイコンが文字化けします．

### 2.5 端末

`termguicolors` を有効にしているため，true color 対応の端末が必要です．クリップボードは OSC52 を使うため，SSH 越しでもコピーが手元の端末に反映されます（端末側の OSC52 対応が必要）．

## 3. Miniconda 環境の準備

`lua/config/options.lua` は Python provider として `~/package/miniconda3/bin/python3` を参照します．

```bash
# Miniconda を ~/package/miniconda3 に導入している場合
~/package/miniconda3/bin/python3 -m pip install pynvim
```

**Miniconda の場所が異なる場合**は，`lua/config/options.lua` の次の 2 行を自分の環境に合わせて書き換えてください．

```lua
vim.env.PATH = home .. "/package/miniconda3/bin:" .. vim.env.PATH
vim.g.python3_host_prog = home .. "/package/miniconda3/bin/python3"
```

例（`~/miniconda3` に入れている場合）．

```lua
vim.env.PATH = home .. "/miniconda3/bin:" .. vim.env.PATH
vim.g.python3_host_prog = home .. "/miniconda3/bin/python3"
```

Python を使わない場合は，この 2 行を削除しても他の機能は動作します．

## 4. インストール

### 4.1 既存設定のバックアップ

既に `~/.config/nvim` がある場合は退避します．

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### 4.2 クローン

```bash
git clone git@github.com:g-hoshino/settings_neovim.git ~/.config/nvim
```

HTTPS を使う場合．

```bash
git clone https://github.com/g-hoshino/settings_neovim.git ~/.config/nvim
```

### 4.3 初回起動

```bash
nvim
```

初回起動時に `lazy.nvim` が自動でクローンされ，続いてプラグインがインストールされます．Tree-sitter パーサーのビルドも走るため，完了まで数分かかります．

インストール状況は `:Lazy` で確認できます．すべて完了したら Neovim を再起動してください．

> GitHub への接続が不安定な環境では，`lua/config/lazy.lua` の `concurrency = 2` を `1` に下げると失敗しにくくなります．

### 4.4 LSP サーバーの導入

LSP サーバーは `mason.nvim` で個別に入れます．Neovim 内で次を実行します．

```vim
:MasonInstall pyright lua-language-server yaml-language-server taplo fortls
```

対応は次のとおりです．

| 言語 | サーバー | Mason パッケージ名 |
|---|---|---|
| Python | pyright | `pyright` |
| Lua | lua_ls | `lua-language-server` |
| YAML | yamlls | `yaml-language-server` |
| TOML | taplo | `taplo` |
| Fortran | fortls | `fortls` |

必要な言語だけ入れて構いません．入れていないサーバーは単に起動しないだけです．

### 4.5 Copilot の認証

GitHub Copilot を使う場合，挿入モードに一度入ってから認証します．

```vim
:Copilot auth
```

表示される URL とコードをブラウザで入力します．Copilot を使わない場合は，`lua/plugins.lua` の `copilot.lua`，`copilot-cmp`，`CopilotChat.nvim` の項目を削除してください．

### 4.6 動作確認

```vim
:checkhealth
```

- `provider.python`：Miniconda の Python が表示されること．
- `lazy`：プラグインのエラーが無いこと．
- `mason`：必要な外部コマンドが検出されていること．

Python ファイルを開いた状態で LSP の接続を確認します．

```vim
:checkhealth vim.lsp
```

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
│       └── lualine.lua       # ステータスライン設定
└── docs/
    └── llm-terminals.md      # LLM ターミナル連携の詳細
```

`lua/plugins.lua` に書いたプラグインを `lazy.nvim` が読み込み，各プラグインの設定は `lua/config/` 以下に分離しています．

## 6. キーマップ

Leader は `<Space>`，local leader は `\` です．

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

> **注意**：`:` と `;` を入れ替えています（ノーマルモード・挿入モードの両方）．`:` を押すと `;` が入力されます．コマンドラインは `;` または `<C-j>` で開きます．この挙動が不要なら `lua/config/keymaps.lua` の該当行を削除してください．

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
| 前の診断へ | `[d` |
| 次の診断へ | `]d` |

### 6.4 補完

| 操作 | キー |
|---|---|
| 補完を開く | `<C-Space>` |
| 次の候補 | `<Tab>` |
| 前の候補 | `<S-Tab>` |
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

プラグインを更新します．

```vim
:Lazy update
```

更新後は `lazy-lock.json` が変化するので，問題なければコミットしてください．

Tree-sitter パーサーを更新します．

```vim
:TSUpdate
```

LSP サーバーを更新します．

```vim
:MasonUpdate
```

## 8. トラブルシュート

### プラグインのインストールが途中で失敗する

GitHub への接続が不安定な場合に起きます．`lua/config/lazy.lua` の `concurrency` を `1` に下げ，`:Lazy restore` でロックファイルの状態に戻してから再試行してください．

### アイコンが文字化けする

端末のフォントが Nerd Font になっていません．端末側の設定を確認してください．

### Python provider が見つからない

`:checkhealth provider` で確認します．`pynvim` が入っていない場合は入れます．

```bash
~/package/miniconda3/bin/python3 -m pip install pynvim
```

パスが異なる場合は，[3. Miniconda 環境の準備](#3-miniconda-環境の準備)のとおり `lua/config/options.lua` を修正します．

### LSP が起動しない

Mason でサーバーが入っているか確認します．

```vim
:Mason
```

`lua/config/lsp.lua` は Mason の `bin` ディレクトリを `PATH` に追加してから各サーバーを起動します．手動で入れたサーバーを使う場合は，そのコマンドが `PATH` にあることを確認してください．

### `live_grep` が動かない

`ripgrep` が必要です．

```bash
rg --version
```

### 背景が透過しない

`lua/config/highlights.lua` で `Normal` などの背景を `none` にしています．端末側の背景が不透明だと透過しません．端末エミュレータの透過設定を確認してください．透過が不要な場合は，`lua/plugins.lua` の `tokyonight.nvim` の `transparent = true` を `false` にし，`lua/config/highlights.lua` の `set_transparent_highlights` の呼び出しを外してください．

### 設定を元に戻したい

クローン前にバックアップしていれば，次で戻せます．

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim
mv ~/.local/state/nvim.bak ~/.local/state/nvim
mv ~/.cache/nvim.bak ~/.cache/nvim
```
