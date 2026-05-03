################################################################################
###                            User Fish Config                              ###
################################################################################

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Homebrew (Apple Silicon)
if test -d /opt/homebrew
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
end

set -gx CPPFLAGS "-I/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk/usr/include/c++/v1/ $CPPFLAGS"

starship init fish | source
