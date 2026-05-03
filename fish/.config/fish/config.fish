################################################################################
###                            User Fish Config                              ###
################################################################################

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx CPPFLAGS "-I/Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk/usr/include/c++/v1/ $CPPFLAGS"

zoxide init fish | source
starship init fish | source
