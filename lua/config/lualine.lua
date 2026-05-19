require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
      refresh_time = 15, -- ~60fps
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
      },
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      {
        'filename',
        path = 1,  -- 0 = just filename, 1 = relative path, 2 = absolute path
        file_status = true, -- displays file status (readonly status, modified status)
        newfile_status = false, -- display new file status (new file means no write after created)
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]',
          newfile = '[New]',        -- Text to show for new created file before first write
        },
      },
    },
    lualine_x = {
        'filesize',
        'encoding',
        'fileformat',
        'filetype',
    },
    lualine_y = {
        'selectioncount',
        'searchcount',
        'progress',
    },
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        mode = 2, -- 0: Shows tab_nr, 1: Shows tab_name, 2: Shows tab_nr + tab_name
        tabs_color = {
          active = 'lualine_a_normal',    -- Color for active tab.
          inactive = 'lualine_a_inactive', -- Color for inactive tab.
        },
      },
    },
    lualine_x = {
      {
      'buffers',
      show_filename_only = false, -- true: shows only filename instead of relative path
      hide_filename_extension = false, -- true: hides filename extension for buffers
      show_modified_status = true, -- true: shows modified status in buffer
      },
    },
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
