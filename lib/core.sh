#!/bin/bash
# Core utility functions for omarchy-menu

# Terminal execution
terminal() {
  xdg-terminal-exec --app-id=org.omarchy.terminal "$@"
}

# Present a floating terminal with presentation mode
present_terminal() {
  omarchy-launch-floating-terminal-with-presentation "$1"
}

# Open file in editor
open_in_editor() {
  notify-send -u low "Editing config file" "$1"
  omarchy-launch-editor "$1"
}

# Installation functions
install() {
  present_terminal "echo 'Installing $1...'; omarchy-pkg-add '$2'"
}

install_and_launch() {
  present_terminal "echo 'Installing $1...'; omarchy-pkg-add '$2' && setsid gtk-launch '$3'"
}

install_font() {
  present_terminal "echo 'Installing $1...'; omarchy-pkg-add '$2' && sleep 2 && omarchy-font-set '$3'"
}

install_terminal() {
  present_terminal "omarchy-install-terminal '$1'"
}

# AUR installation functions
aur_install() {
  present_terminal "echo 'Installing $1 from AUR...'; omarchy-pkg-aur-add '$2'"
}

aur_install_and_launch() {
  present_terminal "echo 'Installing $1 from AUR...'; omarchy-pkg-aur-add '$2' && setsid gtk-launch '$3'"
}
