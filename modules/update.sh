#!/bin/bash
# Update menus functions

show_update_menu() {
  case $(menu "Update" "  Omarchy\n󰔫  Channel\n  Config\n󰸌  Extra Themes\n  Process\n󰇅  Hardware\n  Firmware\n  Password\n  Timezone\n  Time") in
    *Omarchy*) present_terminal omarchy-update ;;
    *Channel*) show_update_channel_menu ;;
    *Config*) show_update_config_menu ;;
    *Themes*) present_terminal omarchy-theme-update ;;
    *Process*) show_update_process_menu ;;
    *Hardware*) show_update_hardware_menu ;;
    *Firmware*) present_terminal omarchy-update-firmware ;;
    *Timezone*) present_terminal omarchy-tz-select ;;
    *Time*) present_terminal omarchy-update-time ;;
    *Password*) show_update_password_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_update_channel_menu() {
  case $(menu "Update channel" "🟢 Stable\n🟡 RC\n🟠 Edge\n🔴 Dev") in
    *Stable*) present_terminal "omarchy-channel-set stable" ;;
    *RC*) present_terminal "omarchy-channel-set rc" ;;
    *Edge*) present_terminal "omarchy-channel-set edge" ;;
    *Dev*) present_terminal "omarchy-channel-set dev" ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_process_menu() {
  case $(menu "Restart" " Hypridle\n Hyprsunset\n󰎟 Mako\n Swayosd\n󰌧 Walker\n󰍜 Waybar") in
    *Hypridle*) omarchy-restart-hypridle ;;
    *Hyprsunset*) omarchy-restart-hyprsunset ;;
    *Mako*) omarchy-restart-mako ;;
    *Swayosd*) omarchy-restart-swayosd ;;
    *Walker*) omarchy-restart-walker ;;
    *Waybar*) omarchy-restart-waybar ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_config_menu() {
  case $(menu "Use default config" " Hyprland\n Hypridle\n Hyprlock\n Hyprsunset\n󱣴 Plymouth\n Swayosd\n Tmux\n󰌧 Walker\n󰍜 Waybar") in
    *Hyprland*) present_terminal omarchy-refresh-hyprland ;;
    *Hypridle*) present_terminal omarchy-refresh-hypridle ;;
    *Hyprlock*) present_terminal omarchy-refresh-hyprlock ;;
    *Hyprsunset*) present_terminal omarchy-refresh-hyprsunset ;;
    *Plymouth*) present_terminal omarchy-refresh-plymouth ;;
    *Swayosd*) present_terminal omarchy-refresh-swayosd ;;
    *Tmux*) present_terminal omarchy-refresh-tmux ;;
    *Walker*) present_terminal omarchy-refresh-walker ;;
    *Waybar*) present_terminal omarchy-refresh-waybar ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_hardware_menu() {
  case $(menu "Restart" " Audio\n󱚾 Wi-Fi\n󰂯 Bluetooth\n󰟸 Trackpad") in
    *Audio*) present_terminal omarchy-restart-pipewire ;;
    *Wi-Fi*) present_terminal omarchy-restart-wifi ;;
    *Bluetooth*) present_terminal omarchy-restart-bluetooth ;;
    *Trackpad*) present_terminal omarchy-restart-trackpad ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_password_menu() {
  case $(menu "Update Password" " Drive Encryption\n User") in
    *Drive*) present_terminal omarchy-drive-password ;;
    *User*) present_terminal passwd ;;
    *) back_to show_update_menu ;;
  esac
}

show_update_channel_menu() {
  case $(menu "Update channel" "🟢 Stable\n🟡 RC\n🟠 Edge\n🔴 Dev") in
    *Stable*) present_terminal "omarchy-channel-set stable" ;;
    *RC*) present_terminal "omarchy-channel-set rc" ;;
    *Edge*) present_terminal "omarchy-channel-set edge" ;;
    *Dev*) present_terminal "omarchy-channel-set dev" ;;
    *) show_update_menu ;;
  esac
}

show_update_process_menu() {
  case $(menu "Restart" "  Hypridle\n  Hyprsunset\n󰎟  Mako\n  Swayosd\n󰌧  Walker\n󰍜  Waybar") in
    *Hypridle*) omarchy-restart-hypridle ;;
    *Hyprsunset*) omarchy-restart-hyprsunset ;;
    *Mako*) omarchy-restart-mako ;;
    *Swayosd*) omarchy-restart-swayosd ;;
    *Walker*) omarchy-restart-walker ;;
    *Waybar*) omarchy-restart-waybar ;;
    *) show_update_menu ;;
  esac
}

show_update_config_menu() {
  case $(menu "Use default config" "  Hyprland\n  Hypridle\n  Hyprlock\n  Hyprsunset\n󱣴  Plymouth\n  Swayosd\n  Tmux\n󰌧  Walker\n󰍜  Waybar") in
    *Hyprland*) present_terminal omarchy-refresh-hyprland ;;
    *Hypridle*) present_terminal omarchy-refresh-hypridle ;;
    *Hyprlock*) present_terminal omarchy-refresh-hyprlock ;;
    *Hyprsunset*) present_terminal omarchy-refresh-hyprsunset ;;
    *Plymouth*) present_terminal omarchy-refresh-plymouth ;;
    *Swayosd*) present_terminal omarchy-refresh-swayosd ;;
    *Tmux*) present_terminal omarchy-refresh-tmux ;;
    *Walker*) present_terminal omarchy-refresh-walker ;;
    *Waybar*) present_terminal omarchy-refresh-waybar ;;
    *) show_update_menu ;;
  esac
}

show_update_hardware_menu() {
  case $(menu "Restart" "  Audio\n󱚾  Wi-Fi\n󰂯  Bluetooth\n󰟸  Trackpad") in
    *Audio*) present_terminal omarchy-restart-pipewire ;;
    *Wi-Fi*) present_terminal omarchy-restart-wifi ;;
    *Bluetooth*) present_terminal omarchy-restart-bluetooth ;;
    *Trackpad*) present_terminal omarchy-restart-trackpad ;;
    *) show_update_menu ;;
  esac
}

show_update_password_menu() {
  case $(menu "Update Password" "  Drive Encryption\n  User") in
    *Drive*) present_terminal omarchy-drive-password ;;
    *User*) present_terminal passwd ;;
    *) show_update_menu ;;
  esac
}
