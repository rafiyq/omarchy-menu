#!/bin/bash
# System controls menu functions (power, logout, etc.)

show_system_menu() {
  local options="  Lock"
  ! toggle_enabled suspend-off && options="$options\n󰒲  Suspend"
  hibernation_available && options="$options\n󰤁  Hibernate"
  options="$options\n󰍃  Logout\n󰜉  Restart\n󰐥  Shutdown"

  case $(menu "System" "$options") in
    *Lock*) wm_lock ;;
    *Suspend*) system_suspend ;;
    *Hibernate*) system_hibernate ;;
    *Logout*) wm_logout ;;
    *Restart*) system_reboot ;;
    *Shutdown*) system_shutdown ;;
    *) back_to show_main_menu ;;
  esac
}
