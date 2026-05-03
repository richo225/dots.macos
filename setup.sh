#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

PACKAGES=(aerospace alacritty borders btop fastfetch fish git mise nvim starship)

echo "Installing brew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "Stowing dotfiles to $HOME"

for pkg in "${PACKAGES[@]}"; do
    if stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "$pkg" 2>/dev/null; then
        echo "✅ $pkg"
    else
        echo "⚠️  $pkg — conflict detected, run manually:"
        echo "    stow --dir=$DOTFILES_DIR --target=$HOME --no-folding $pkg"
    fi
done

echo "Done!"
