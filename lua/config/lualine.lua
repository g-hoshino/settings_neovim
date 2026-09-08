------------------------------------------------------------
-- lualine
--
-- 既定値と同じ設定は書かない．ここに残っているのは
-- lualine のデフォルトと異なる項目だけ．
------------------------------------------------------------
require('lualine').setup {
  options = {
    -- ウィンドウごとに statusline を組み立てず，画面下に 1 本だけ持つ．
    -- options.lua の laststatus = 3 と対になっている．
    globalstatus = true,

    refresh = {
      -- refresh_time は「再描画キューを見に行く間隔」．
      -- 既定の 16ms（~60fps）だとカーソル移動・タイプ中に statusline と tabline を
      -- 毎秒数十回組み直すことになるため，60ms（~16fps）まで落とす．
      refresh_time = 60,

      -- 既定のイベント一覧から CursorMovedI だけを外したもの．
      -- CursorMovedI は挿入中の 1 打鍵ごとに発火する．
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'ModeChanged',
      },
    },
  },

  -- lualine_a / lualine_b / lualine_z は既定のまま．
  -- lualine_x も既定（encoding / fileformat / filetype）．
  -- 'filesize' は再描画のたびに stat システムコールを呼ぶため入れていない．
  sections = {
    lualine_c = {
      { 'filename', path = 1 }, -- 0 = filename のみ, 1 = 相対パス, 2 = 絶対パス
    },
    lualine_y = {
      'selectioncount',
      -- searchcount は hlsearch が有効な間，再描画のたびに
      -- vim.fn.searchcount() を呼ぶ．走査範囲と待ち時間を絞る．
      { 'searchcount', maxcount = 99, timeout = 50 },
      'progress',
    },
  },

  -- inactive_sections は既定のまま．

  tabline = {
    lualine_a = {
      {
        'tabs',
        mode = 2, -- 0: tab_nr, 1: tab_name, 2: tab_nr + tab_name
        -- 既定では lualine の初期化時のモードから色名を決めるため，明示的に固定する．
        tabs_color = {
          active = 'lualine_a_normal',
          inactive = 'lualine_a_inactive',
        },
      },
    },
    lualine_x = {
      -- 既定は show_filename_only = true（ファイル名のみ）．
      { 'buffers', show_filename_only = false },
    },
  },
}
