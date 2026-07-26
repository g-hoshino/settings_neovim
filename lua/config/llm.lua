local M = {}

local terminals = {}
local active_name = nil

local function project_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local start = current_file ~= "" and vim.fs.dirname(current_file) or vim.fn.getcwd()
  return vim.fs.root(start, { ".git", "pyproject.toml", "Cargo.toml", "package.json" }) or vim.fn.getcwd()
end

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function load_toggleterm()
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    lazy.load({ plugins = { "toggleterm.nvim" } })
  end

  local ok_terminal, terminal = pcall(require, "toggleterm.terminal")
  if not ok_terminal then
    vim.notify("toggleterm.nvim could not be loaded", vim.log.levels.ERROR)
    return nil
  end

  return terminal.Terminal
end

local function terminal_key(name, cwd)
  return name .. "\0" .. cwd
end

local function get_terminal(name, command)
  if not executable(command) then
    vim.notify(command .. " CLI is not available in PATH", vim.log.levels.ERROR)
    return nil
  end

  local Terminal = load_toggleterm()
  if not Terminal then
    return nil
  end

  local cwd = project_root()
  local key = terminal_key(name, cwd)

  if not terminals[key] then
    terminals[key] = Terminal:new({
      cmd = command,
      dir = cwd,
      direction = "vertical",
      size = function()
        return math.max(50, math.floor(vim.o.columns * 0.42))
      end,
      hidden = true,
      close_on_exit = false,
      start_in_insert = true,
      auto_scroll = true,
      display_name = name,
      on_open = function(term)
        active_name = name
        vim.cmd("startinsert!")
        vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
          buffer = term.bufnr,
          silent = true,
          desc = "Leave terminal mode",
        })
        vim.keymap.set("t", "<C-e>", [[<C-\><C-n><cmd>close<CR>]], {
          buffer = term.bufnr,
          silent = true,
          desc = "Hide LLM terminal",
        })
      end,
    })
  end

  active_name = name
  return terminals[key]
end

local function toggle(name, command)
  local term = get_terminal(name, command)
  if term then
    term:toggle()
  end
end

function M.claude()
  toggle("Claude", "claude")
end

function M.codex()
  toggle("Codex", "codex")
end

function M.choose()
  local choices = {}
  if executable("claude") then
    table.insert(choices, "Claude")
  end
  if executable("codex") then
    table.insert(choices, "Codex")
  end

  if #choices == 0 then
    vim.notify("Neither claude nor codex CLI is available in PATH", vim.log.levels.ERROR)
    return
  end

  vim.ui.select(choices, { prompt = "LLM terminal" }, function(choice)
    if choice == "Claude" then
      M.claude()
    elseif choice == "Codex" then
      M.codex()
    end
  end)
end

function M.status()
  vim.notify(active_name and ("Active LLM: " .. active_name) or "No LLM terminal has been opened")
end

vim.api.nvim_create_user_command("Claude", M.claude, { desc = "Toggle Claude Code terminal" })
vim.api.nvim_create_user_command("Codex", M.codex, { desc = "Toggle Codex CLI terminal" })
vim.api.nvim_create_user_command("LLM", M.choose, { desc = "Choose an available LLM terminal" })
vim.api.nvim_create_user_command("LLMStatus", M.status, { desc = "Show the active LLM terminal" })

vim.keymap.set("n", "<leader>aa", M.choose, { silent = true, desc = "Choose LLM terminal" })
vim.keymap.set("n", "<leader>ac", M.claude, { silent = true, desc = "Toggle Claude terminal" })
vim.keymap.set("n", "<leader>ax", M.codex, { silent = true, desc = "Toggle Codex terminal" })

vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "TermClose" }, {
  group = vim.api.nvim_create_augroup("ReloadFilesEditedByLLM", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

return M
