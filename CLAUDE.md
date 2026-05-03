# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

macOS dotfiles repo managed with [GNU Stow](https://www.gnu.org/software/stow/). Each subdirectory is a stow package symlinked into `~/`. Editing files in the repo immediately affects the live config — no sync step needed.

## Installation

```bash
./setup.sh          # installs Homebrew packages + stows all packages
fisher update       # reinstalls fish plugins from fish_plugins
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

| Dir | Tool | Format |
|-----|------|--------|
| `aerospace/` | AeroSpace tiling WM | TOML |
| `alacritty/` | Alacritty terminal | TOML |
| `borders/` | JankyBorders window decorations | shell |
| `btop/` | btop++ system monitor | conf + theme |
| `fastfetch/` | System info display | JSONC |
| `fish/` | Fish shell | Fish script |
| `mise/` | mise version manager | TOML |
| `nvim/` | Neovim (LazyVim) | Lua |
| `starship/` | Starship prompt | TOML |

`Brewfile` lists all Homebrew packages (formulae, casks, taps).

## Fish layout note

`~/.config/fish/` contains a mix of repo-managed and plugin-managed files. Only repo-managed files are stowed:

- **Stowed**: `config.fish`, `conf.d/user_*.fish`, `functions/<custom>.fish`, `fish_plugins`
- **Not stowed**: fisher plugin files (fzf, zoxide, upto) — fisher owns these
- **Gitignored**: `fish_variables` — stores universal variables including secrets (`set -Ux`)

Fisher plugins are listed in `fish_plugins`. On a new machine, run `fisher update` after stowing to reinstall them.

Don't commit fisher plugin files or `fish_variables` to the repo.

## Secrets

Never commit secrets, API tokens, passwords, or credentials. This is a public repo.

- Shell env vars go in `fish_variables` via `set -Ux` — gitignored, never stowed
- If a secret is accidentally staged, remove it and rotate the credential immediately

## Theme switching

Themes live in `themes/<name>/` and are applied with:

```fish
theme-set <name>   # e.g. theme-set tokyo-night
```

Each theme directory contains a `colors.toml` (shared palette) and optionally `neovim.lua` and `backgrounds/`. The `default/themed/` directory holds templates that `theme-set` renders via sed substitution.

`theme-set` writes three generated files that are **not** committed:

| Generated file | Source template |
|---|---|
| `~/.config/alacritty/colors.toml` | `default/themed/alacritty.toml.tpl` |
| `~/.config/btop/themes/current.theme` | `default/themed/btop.theme.tpl` |
| `~/.config/nvim/lua/current_theme.lua` | `themes/<name>/neovim.lua` (copied verbatim) |

The active theme name is recorded in `~/.config/dots-theme`.

On a fresh install, run `theme-set <name>` after stowing to generate these files. Neovim falls back to tokyo-night if `current_theme.lua` is missing.

## Conventions

- **Theme**: Switchable via `theme-set` — tokyo-night is the default/fallback.
- **Keybindings**: vim-style (`hjkl`) throughout, including AeroSpace window navigation.
- **Shell**: Fish only. No zsh/bash configs live here.
- **Neovim**: LazyVim starter — `nvim/init.lua` is minimal boilerplate; plugins managed by Lazy.
