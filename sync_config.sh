#!/bin/bash

set -e

echo "Copying config directories..."
cp -r ~/.config/{aerospace,alacritty,btop,fastfetch,fish,nvim} .

echo "Copying starship config..."
cp ~/.config/starship.toml .

echo "Dumping Brewfile..."
brew bundle dump --force

echo "🎉 All done!"