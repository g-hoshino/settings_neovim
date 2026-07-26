# Terminal-based LLM integration

This configuration uses the existing `toggleterm.nvim` installation. No additional Neovim plugin is required.

## Required CLI tools

Install either or both commands and make sure they are available in `PATH`:

```bash
claude --version
codex --version
```

Authentication is handled by each CLI, not by Neovim.

## Commands and key mappings

| Action | Command | Key |
|---|---|---|
| Choose an available LLM | `:LLM` | `<leader>aa` |
| Toggle Claude Code | `:Claude` | `<leader>ac` |
| Toggle Codex CLI | `:Codex` | `<leader>ax` |
| Show the last selected LLM | `:LLMStatus` | - |
| Leave terminal mode | - | `<Esc><Esc>` |
| Hide the LLM terminal | - | `<C-e>` |

The existing generic floating terminal remains available through `<C-e>` in normal mode.

## Behavior

- Claude and Codex use independent terminal sessions.
- A session is retained separately for each project root.
- The project root is detected from `.git`, `pyproject.toml`, `Cargo.toml`, or `package.json`.
- The terminal opens as a right-hand vertical split so the source buffer stays visible.
- Files modified by an LLM are checked automatically when focus returns to Neovim or terminal mode ends.

## Suggested workflow

1. Open Neovim from the project or open a file in the project.
2. Run `<leader>ac` or `<leader>ax`.
3. Ask the CLI to inspect or edit files while keeping the source buffer visible.
4. Review the changed buffers and Git diff before committing.
