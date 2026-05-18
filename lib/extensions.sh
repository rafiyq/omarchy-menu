#!/bin/bash
# User extension loading functionality

load_user_extensions() {
  local extensions_dir
  extensions_dir="$(wmenu_config_dir)/extensions"
  local menu_extension="$extensions_dir/menu.sh"

  [[ -d "$extensions_dir" ]] || mkdir -p "$extensions_dir"

  # shellcheck source=/dev/null
  [[ -f "$menu_extension" ]] && source "$menu_extension" || true
}

load_user_extensions
