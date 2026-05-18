#!/bin/bash
# Core utility functions — terminal, install helpers
# Sources: lib/platform.sh, lib/pkg.sh, lib/services.sh

# Detect available terminal emulator
_detect_terminal() {
  local t
  for t in foot kitty alacritty ghostty wezterm; do
    command -v "$t" >/dev/null 2>&1 && { echo "$t"; return; }
  done
  echo ""
}

# Execute command in a terminal emulator
terminal() {
  local term
  term=$(_detect_terminal)
  if [[ -n "$term" ]]; then
    "$term" "$@" &
  elif command -v xdg-terminal-exec >/dev/null 2>&1; then
    xdg-terminal-exec "$@"
  else
    echo "Error: no terminal emulator found" >&2
    return 1
  fi
}

# Present a floating terminal with presentation mode (pause after execution)
present_terminal() {
  local term
  term=$(_detect_terminal)
  if [[ -n "$term" ]]; then
    "$term" -- /bin/bash -c "$1; echo; read -rp 'Press Enter to close...'"
  else
    echo "Error: no terminal emulator found" >&2
    return 1
  fi
}

# Open file in editor
open_in_editor() {
  notify-send -u low "Editing config file" "$1"
  local editor="${EDITOR:-nvim}"
  if command -v "$editor" >/dev/null 2>&1; then
    terminal "$editor" "$1"
  else
    terminal vi "$1"
  fi
}

# Installation helpers — delegate to pkg.sh
install() {
  local package
  package=$(pkg_name "$2")
  present_terminal "echo 'Installing $1...'; pkg_install '$package'"
}

install_and_launch() {
  local package
  package=$(pkg_name "$2")
  present_terminal "echo 'Installing $1...'; pkg_install '$package' && setsid gtk-launch '$3'"
}

install_font() {
  local package
  package=$(pkg_name "$2")
  present_terminal "echo 'Installing $1...'; pkg_install '$package' && sleep 2 && font_set '$3'"
}

install_terminal() {
  local package
  package=$(pkg_name "$1")
  pkg_install "$package"
}

aur_install() {
  local package
  package=$(pkg_name "$2")
  present_terminal "echo 'Installing $1 from AUR...'; pkg_thirdparty_install '$package'"
}

aur_install_and_launch() {
  local package
  package=$(pkg_name "$2")
  present_terminal "echo 'Installing $1 from AUR...'; pkg_thirdparty_install '$package' && setsid gtk-launch '$3'"
}
