#!/bin/bash
# Menu display functions with rofi/walker abstraction

# Get menu backend configuration
get_menu_backend() {
  # Check environment variable (new name first, then fallback to old)
  if [[ -n "${WMENU_MENU_BACKEND:-}" ]]; then
    echo "$WMENU_MENU_BACKEND"
    return
  fi
  if [[ -n "${OMARCHY_MENU_BACKEND:-}" ]]; then
    echo "$OMARCHY_MENU_BACKEND"
    return
  fi

  # Auto-detect: prefer walker, then rofi, then fall back to tui
  if command_available walker; then
    echo "walker"
  elif command_available rofi; then
    echo "rofi"
  else
    echo "tui"
  fi
}

# Check if a command is available
command_available() {
  command -v "$1" >/dev/null 2>&1
}

# Toggle existing menu - close if already open
toggle_existing_menu() {
  if pgrep -f "walker.*--dmenu" >/dev/null; then
    walker --close >/dev/null 2>&1
    exit 0
  fi
  if pgrep -f "rofi.*-dmenu" >/dev/null; then
    pkill -f "rofi.*-dmenu"
    exit 0
  fi
}

# Display a menu and return selected item
# Usage: show_menu "Prompt" "Option1\nOption2\nOption3" "[extra_args]" "[preselect]"
show_menu() {
  local prompt="$1"
  local options="$2"
  local extra="$3"
  local preselect="$4"

  local backend
  backend=$(get_menu_backend)

  # Prepare extra arguments
  local args=()
  if [[ -n "$extra" ]]; then
    read -r -a args <<<"$extra"
  fi

  # Handle preselection
  if [[ -n "$preselect" ]]; then
    local index
    index=$(echo -e "$options" | grep -nxF "$preselect" | cut -d: -f1)
    if [[ -n "$index" ]]; then
      args+=("-c" "$index")
    fi
  fi

  case "$backend" in
    rofi)
      if ! command_available rofi; then
        echo "Error: rofi is not available" >&2
        return 1
      fi
      local rofi_args=(rofi -dmenu -p "${prompt}…" "${args[@]}")
      echo -e "$options" | "${rofi_args[@]}"
      return
      ;;
    walker)
      # Use walker backend (default)
      if ! command_available walker; then
        echo "Error: walker is not available" >&2
        return 1
      fi
      # Original walker implementation (using walker directly)
      echo -e "$options" | walker --dmenu --width 295 --minheight 1 --maxheight 630 -p "$prompt…" "${args[@]}" 2>/dev/null
      return
      ;;
    tui)
      # Pure bash TUI menu — no external dependencies
      tui_menu "$prompt" "$options"
      return
      ;;
    *)
      echo "Error: unknown menu backend '$backend'" >&2
      return 1
      ;;
  esac
}

# Original menu function maintained for backward compatibility
# This now uses the abstraction layer underneath
menu() {
  local prompt="$1"
  local options="$2"
  local extra="$3"
  local preselect="$4"

  show_menu "$prompt" "$options" "$extra" "$preselect"
}
