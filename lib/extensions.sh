#!/bin/bash
# User extension loading functionality

# Load user extensions if they exist
# This file should be sourced AFTER all module files so user overrides take effect
load_user_extensions() {
  local extensions_dir="$HOME/.config/omarchy/extensions"
  local menu_extension="$extensions_dir/menu.sh"

  [[ -d "$extensions_dir" ]] || mkdir -p "$extensions_dir"

  # shellcheck source=/dev/null
  [[ -f "$menu_extension" ]] && source "$menu_extension" || true
}

load_user_extensions
