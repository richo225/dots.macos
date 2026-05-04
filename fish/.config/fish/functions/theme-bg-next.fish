function theme-bg-next --description "Cycle to the next background for the current theme"
    set -l DOTS ~/code/dots.macos

    set -l theme (cat ~/.config/dots-theme 2>/dev/null)
    if test -z "$theme"
        echo "theme-bg-next: no active theme"
        return 1
    end

    set -l bg_dir $DOTS/themes/$theme/backgrounds
    if not test -d $bg_dir
        echo "theme-bg-next: no backgrounds for '$theme'"
        return 1
    end

    set -l bg_files (command ls $bg_dir | sort)
    if test (count $bg_files) -eq 0
        echo "theme-bg-next: no background files found"
        return 1
    end

    set -l current (cat ~/.config/dots-theme-bg 2>/dev/null)
    set -l next_name $bg_files[1]
    for i in (seq (count $bg_files))
        if test "$bg_files[$i]" = "$current"
            set -l next_i (math "($i % "(count $bg_files)") + 1")
            set next_name $bg_files[$next_i]
            break
        end
    end

    set -l bg_path (realpath $bg_dir/$next_name)
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$bg_path\""
    echo $next_name > ~/.config/dots-theme-bg
    echo "theme-bg-next: $next_name"
end
