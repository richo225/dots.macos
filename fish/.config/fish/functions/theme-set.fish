function theme-set --description "Switch dots.macos theme"
    set -l DOTS ~/code/dots.macos
    set -l THEMES_DIR $DOTS/themes
    set -l TEMPLATES_DIR $DOTS/default/themed

    if test -z "$argv[1]"
        echo "Usage: theme-set <theme-name>"
        echo ""
        echo "Available themes:"
        for d in $THEMES_DIR/*/
            echo "  "(basename $d)
        end
        return 1
    end

    set -l THEME $argv[1]
    set -l THEME_DIR $THEMES_DIR/$THEME

    if not test -d $THEME_DIR
        echo "theme-set: unknown theme '$THEME'"
        return 1
    end

    set -l COLORS_FILE $THEME_DIR/colors.toml

    if not test -f $COLORS_FILE
        echo "theme-set: no colors.toml for '$THEME'"
        return 1
    end

    # Build sed script from colors.toml using awk (reliable quote/whitespace handling)
    set -l sed_script (mktemp)
    awk -F'=' '/^[[:space:]]*#/{next} /^[[:space:]]*$/{next} NF>=2{key=$1; gsub(/[[:space:]]/,"",key); value=$0; sub(/^[^=]+=/,"",value); gsub(/^[[:space:]]*/,"",value); gsub(/^"/,"",value); gsub(/"[[:space:]]*$/,"",value); stripped=value; sub(/^#/,"",stripped); printf "s|{{ %s }}|%s|g\n",key,value; printf "s|{{ %s_strip }}|%s|g\n",key,stripped}' $COLORS_FILE > $sed_script

    # Generate alacritty colors
    mkdir -p ~/.config/alacritty
    sed -f $sed_script $TEMPLATES_DIR/alacritty.toml.tpl > ~/.config/alacritty/colors.toml

    # Generate btop theme
    mkdir -p ~/.config/btop/themes
    sed -f $sed_script $TEMPLATES_DIR/btop.theme.tpl > ~/.config/btop/themes/current.theme

    # Apply fish colours
    set -l fish_theme_file (mktemp)
    sed -f $sed_script $TEMPLATES_DIR/fish.theme.tpl > $fish_theme_file
    while read -l line
        string match -qr '^\s*#' -- $line; and continue
        string match -qr '^\s*$' -- $line; and continue
        set -l varname (string match -r '^\S+' -- $line)
        set -l value_str (string replace -r '^\S+\s*' '' -- $line)
        if test -n "$value_str"
            set -U $varname (string split -- ' ' $value_str)
        end
    end < $fish_theme_file
    rm $fish_theme_file

    # Update neovim colorscheme
    if test -f $THEME_DIR/neovim.lua
        cp $THEME_DIR/neovim.lua $DOTS/nvim/.config/nvim/lua/plugins/theme.lua
    end

    # Save current theme name
    echo $THEME > ~/.config/dots-theme

    rm $sed_script
    echo "theme-set: switched to $THEME"
end
