#!/bin/bash

# set var for omarchy directory
OMARCHY_TOKYO_NIGHT_DIR="$HOME/.local/share/omarchy/themes/tokyo-night"

set -e

echo "Copying config directories to repo..."
cp -r ~/.config/{aerospace,alacritty,borders,fastfetch,fish,nvim,starship} .

echo "Copying alacritty config..."
cp -r ~/.config/alacritty .
echo "Merging alacritty theme..."
sed -i '' '/general.import/d' alacritty/alacritty.toml
cat $OMARCHY_TOKYO_NIGHT_DIR/alacritty.toml >>alacritty/alacritty.toml

echo "Copying btop theme..."
cp $OMARCHY_TOKYO_NIGHT_DIR/btop.theme btop/

echo "Dumping Brewfile..."
brew bundle dump --force

echo "🎉 All done!"
