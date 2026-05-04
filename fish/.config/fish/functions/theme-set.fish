function theme-set --description "Switch dots.macos theme"
    set -l DOTS ~/code/dots.macos
    set -l THEMES_DIR $DOTS/themes
    set -l TEMPLATES_DIR $DOTS/default/themed

    set -l THEME ""
    set -l SELECTED_BG ""

    if test -z "$argv[1]"
        set THEME (command ls $THEMES_DIR | fzf --prompt="theme > " \
            --height=~70% \
            --preview="bat --style=plain --color=always $THEMES_DIR/{}/colors.toml 2>/dev/null" \
            --preview-window=right:60%)
        test -z "$THEME"; and return 0

        set SELECTED_BG (command ls $THEMES_DIR/$THEME/backgrounds | sort | fzf --prompt="background > " --height=~40%)
        test -z "$SELECTED_BG"; and return 0
    else
        set THEME $argv[1]
    end
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

    # Generate alacritty colors and reload all open windows
    mkdir -p ~/.config/alacritty
    sed -f $sed_script $TEMPLATES_DIR/alacritty.toml.tpl > ~/.config/alacritty/colors.toml
    alacritty msg config -w -1 --reset 2>/dev/null; true

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
        cp $THEME_DIR/neovim.lua ~/.config/nvim/lua/current_theme.lua
    end

    # Save current theme name
    echo $THEME > ~/.config/dots-theme

    # Set first background for the theme
    set -l bg_dir $THEME_DIR/backgrounds
    if test -d $bg_dir
        set -l bg_files (command ls $bg_dir | sort)
        if test (count $bg_files) -gt 0
            set -l bg_name $bg_files[1]
            if test -n "$SELECTED_BG"
                set bg_name $SELECTED_BG
            end
            set -l bg_path (realpath $bg_dir/$bg_name)
            osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$bg_path\""
            echo $bg_name > ~/.config/dots-theme-bg
        end
    end

    rm $sed_script
    echo "theme-set: switched to $THEME"
end
