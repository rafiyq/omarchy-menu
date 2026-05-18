#!/bin/bash
# Update menus functions

show_update_menu() {
  case $(menu "Update" "  System\n󰇅  Firmware\n  Process\n  Hardware\n  Timezone\n  Time\n  Password") in
    *System*) present_terminal pkg_update ;;
    *Firmware*) present_terminal update_firmware ;;
    *Process*) show_update_process_menu ;;
    *Hardware*) show_update_hardware_menu ;;
    *Timezone*) present_terminal tz_select ;;
    *Time*) present_terminal update_time ;;
    *Password*) present_terminal passwd ;;
    *) back_to show_main_menu ;;
  esac
}

show_update_process_menu() {
  case $(menu "Restart" " Hypridle\n Hyprsunset\n󰎟 Mako\n Swayosd\n󰌧 Walker\n󰍜 Waybar") in
    *Hypridle*) restart_hypridle ;;
    *Hyprsunset*) restart_hyprsunset ;;
    *Mako*) restart_mako ;;
    *Swayosd*) restart_swayosd ;;
    *Walker*) restart_walker ;;
    *Waybar*) restart_waybar ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_hardware_menu() {
  case $(menu "Restart" " Audio\n󱚾 Wi-Fi\n󰂯 Bluetooth") in
    *Audio*) restart_pipewire ;;
    *Wi-Fi*) restart_wifi ;;
    *Bluetooth*) restart_bluetooth ;;
    *) back_to show_update_menu ;;
  esac
}
