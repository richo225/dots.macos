function n -w file -d "Open Neovim in the current directory or specified file/line. Usage: n [file[:line]]"
    if test (count $argv) -eq 0
        command nvim .
    else if test (count $argv) -eq 1
        set -l parts (string split ':' $argv[1])
        if test (count $parts) -eq 1
            command nvim $argv[1]
        else if test (count $parts) -eq 2
            command nvim +$parts[2] $parts[1]
        else
            echo "Usage: n [file[:line]]"
            return 1
        end
    else
        echo "Usage: n [file[:line]]"
        return 1
    end
end