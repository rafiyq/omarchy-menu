#!/bin/bash
# Application launching functions

show_apps_menu() {
  local backend
  backend=$(get_menu_backend)

  case "$backend" in
    rofi)
      if command_available rofi; then
        rofi -show drun
      else
        echo "Error: rofi is not available" >&2
        return 1
      fi
      ;;
    walker)
      if command_available walker; then
        walker -p "Launch…"
      else
        echo "Error: walker is not available" >&2
        return 1
      fi
      ;;
    *)
      echo "Error: unknown menu backend '$backend'" >&2
      return 1
      ;;
  esac
}
