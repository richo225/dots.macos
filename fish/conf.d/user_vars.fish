################################################################################
###                          User Fish Variables                           ###
################################################################################

# Set fish greeting
set -g fish_greeting

# Set editor
set -x EDITOR nvim
set -x SUDO_EDITOR $EDITOR

# golang
set -x GOPATH (go env GOPATH)
set -x GOBIN (go env GOPATH)/bin
set -x PATH $PATH $GOBIN
