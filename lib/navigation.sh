#!/bin/bash
# Menu navigation and routing logic

# Set to true when going directly to a submenu, so we can exit directly
BACK_TO_EXIT=false

# Navigate back to parent menu or exit
back_to() {
  local parent_menu="$1"

  if [[ $BACK_TO_EXIT == "true" ]]; then
    exit 0
  elif [[ -n $parent_menu ]]; then
    "$parent_menu"
  else
    show_main_menu
  fi
}

# Route to appropriate menu based on user selection
go_to_menu() {
  case "${1,,}" in
    *apps*) show_apps_menu ;;
    *learn*) show_learn_menu ;;
    *trigger*) show_trigger_menu ;;
    *toggle*) show_toggle_menu ;;
    *hardware*) show_hardware_menu ;;
    *share*) show_share_menu ;;
    *reminder-set*) show_custom_reminder_input ;;
    *reminder*) show_reminder_menu ;;
    *background*) show_background_menu ;;
    *capture*) show_capture_menu ;;
    *style*) show_style_menu ;;
    *theme*) show_theme_menu ;;
    *screenrecord*) show_screenrecord_menu ;;
    *setup*) show_setup_menu ;;
    *power*) show_setup_power_menu ;;
    *install*) show_install_menu ;;
    *remove*) show_remove_menu ;;
    *update*) show_update_menu ;;
    *about*) show_about ;;
    *system*) show_system_menu ;;
  esac
}
