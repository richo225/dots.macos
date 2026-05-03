# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

macOS dotfiles repo managed with [GNU Stow](https://www.gnu.org/software/stow/). Each subdirectory is a stow package symlinked into `~/`. Editing files in the repo immediately affects the live config — no sync step needed.

## Installation

```bash
./setup.sh          # installs Homebrew packages + stows all packages
```

To stow a single package manually:

```bash
stow --dir=~/code/dots.macos --target=~ --no-folding fish
```

`--no-folding` prevents stow from symlinking whole directories when only some files are managed — important for fish since plugin-managed files coexist in the same dirs.

## Structure

Each package follows the layout `<pkg>/.config/<pkg>/` so stow (targeting `~`) places files at `~/.config/<pkg>/`. For example:

```
fish/
└── .config/
    └── fish/
        ├── config.fish      →  ~/.config/fish/config.fish
        └── functions/       →  ~/.config/fish/functions/
```

| Dir | Tool | Target path |
|-----|------|-------------|

| Dir | Tool | Format |
|-----|------|--------|
| `aerospace/` | AeroSpace tiling WM | TOML |
| `alacritty/` | Alacritty terminal | TOML |
| `borders/` | JankyBorders window decorations | shell |
| `btop/` | btop++ system monitor | conf + theme |
| `fastfetch/` | System info display | JSONC |
| `fish/` | Fish shell | Fish script |
| `git/` | Global git config | gitignore |
| `mise/` | mise version manager | TOML |
| `nvim/` | Neovim (LazyVim) | Lua |
| `starship/` | Starship prompt | TOML |

All packages use `~/.config/<name>/` as their target path.

`Brewfile` lists all Homebrew packages (formulae, casks, taps).

## Fish layout note

`~/.config/fish/` contains a mix of repo-managed files and plugin-generated files (fisher, nvm, omf, yvm). Only repo files are stowed. Don't add plugin-generated files to the repo.

## Conventions

- **Theme**: Tokyo Night everywhere — alacritty, starship, btop all use the same palette.
- **Keybindings**: vim-style (`hjkl`) throughout, including AeroSpace window navigation.
- **Shell**: Fish only. No zsh/bash configs live here.
- **Neovim**: LazyVim starter — `nvim/init.lua` is minimal boilerplate; plugins managed by Lazy.
