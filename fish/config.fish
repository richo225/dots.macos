################################################################################
###                            User Fish Config                              ###
################################################################################

if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
    echo
    commandline -f repaint
end

source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc

zoxide init fish | source
starship init fish | source
