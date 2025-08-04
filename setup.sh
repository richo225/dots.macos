#!/bin/bash

CONFIG_DIR="$HOME/.config"

echo "Installing brew packages..."
brew bundle

echo "⚠️  This will copy dotfiles to $CONFIG_DIR"
echo "You'll be prompted for each directory that would be copied."
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

for dir in */; do
    dirname=${dir%/}
    read -p "Copy $dirname to $CONFIG_DIR? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp -r "$dir" "$CONFIG_DIR/"
        echo "✅ Copied $dirname"
    else
        echo "⏭️  Skipped $dirname"
    fi
done

read -p "Copy starship.toml to $CONFIG_DIR? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp starship.toml "$CONFIG_DIR/"
    echo "✅ Copied starship.toml"
else
    echo "⏭️  Skipped starship.toml"
fi

echo "Done!"