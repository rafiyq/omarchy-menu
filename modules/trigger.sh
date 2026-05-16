#!/bin/bash
# Trigger actions menu functions (reminders, capture, etc.)

show_trigger_menu() {
  case $(menu "Trigger" "󰔛  Reminder\n  Capture\n󰧸  Transcode\n  Share\n󰔎  Toggle\n  Hardware") in
    *Reminder*) show_reminder_menu ;;
    *Capture*) show_capture_menu ;;
    *Transcode*) omarchy-transcode || back_to show_trigger_menu ;;
    *Share*) show_share_menu ;;
    *Toggle*) show_toggle_menu ;;
    *Hardware*) show_hardware_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_reminder_menu() {
  case $(menu "Reminder" "󰔛  Set one\n󰔛  Show all\n󰔛  Clear all") in
    *Set*) show_custom_reminder_input ;;
    *"Show all"*) omarchy-reminder show ;;
    *"Clear all"*) omarchy-reminder clear ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_custom_reminder_input() {
  local minutes
  minutes=$(omarchy-menu-input "Remind in minutes")

  if [[ $minutes =~ ^[0-9]+$ ]] && ((minutes > 0)); then
    show_reminder_message_input "$minutes"
  elif [[ -n $minutes ]]; then
    omarchy-notification-send "󰔛" "Invalid reminder" "Enter the number of minutes" -u critical
    show_custom_reminder_input
  else
    back_to show_reminder_menu
  fi
}

show_reminder_message_input() {
  local minutes="$1"
  local message
  message=$(omarchy-menu-input "Reminder message")

  if [[ -n $message ]]; then
    omarchy-reminder "$minutes" "$message"
  else
    omarchy-reminder "$minutes"
  fi
}

show_capture_menu() {
  case $(menu "Capture" "  Screenshot\n  Screenrecord\n󰴑  Text Extraction\n󰃉  Color") in
    *Screenshot*) omarchy-capture-screenshot ;;
    *Screenrecord*) show_screenrecord_menu ;;
    *Text*) omarchy-capture-text-extraction ;;
    *Color*) pkill hyprpicker || hyprpicker -a ;;
    *) back_to show_trigger_menu ;;
  esac
}

get_webcam_list() {
  v4l2-ctl --list-devices 2>/dev/null | while IFS= read -r line; do
    if [[ $line != $'\t'* && -n $line ]]; then
      local name="$line"
      IFS= read -r device || break
      device=$(echo "$device" | tr -d '\t' | head -1)
      [[ -n $device ]] && echo "$device  $name"
    fi
  done
}

show_webcam_select_menu() {
  local devices
  devices=$(get_webcam_list)
  local count=0
  [[ -n "$devices" ]] && count=$(printf '%s\n' "$devices" | grep -c . 2>/dev/null || echo 0)

  if [[ -z $devices ]] || ((count == 0)); then
    notify-send "No webcam devices found" -u critical -t 3000
    return 1
  fi

  if ((count == 1)); then
    echo "$devices" | awk '{print $1}'
  else
    menu "Select Webcam" "$devices" | awk '{print $1}'
  fi
}

show_screenrecord_menu() {
  omarchy-capture-screenrecording --stop-recording && exit 0

  case $(menu "Screenrecord" "  With no audio\n  With desktop audio\n  With desktop + microphone audio\n  With desktop + microphone audio + webcam") in
    *"With no audio") omarchy-capture-screenrecording ;;
    *"With desktop audio") omarchy-capture-screenrecording --with-desktop-audio ;;
    *"With desktop + microphone audio") omarchy-capture-screenrecording --with-desktop-audio --with-microphone-audio ;;
    *"With desktop + microphone audio + webcam")
      local device
      device=$(show_webcam_select_menu) || {
        back_to show_capture_menu
        return
      }
      omarchy-capture-screenrecording --with-desktop-audio --with-microphone-audio --with-webcam --webcam-device="$device"
      ;;
    *) back_to show_capture_menu ;;
  esac
}

show_share_menu() {
  case $(menu "Share" "  Clipboard\n  File \n  Folder") in
    *Clipboard*) omarchy-menu-share clipboard ;;
    *File*) terminal bash -c "omarchy-menu-share file" ;;
    *Folder*) terminal bash -c "omarchy-menu-share folder" ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_toggle_menu() {
  local options="󱄄  Screensaver\n󰔎  Nightlight\n󱫖  Idle Lock\n󰂛  Notifications\n󰍜  Top Bar\n󱂬  Workspace Layout\n  Window Gaps\n  1-Window Ratio\n󰍹  Monitor Scaling\n  Direct Boot\n󰟵  Passwordless Sudo"

  case $(menu "Toggle" "$options") in
    *Screensaver*) omarchy-toggle-screensaver ;;
    *Nightlight*) omarchy-toggle-nightlight ;;
    *Idle*) omarchy-toggle-idle ;;
    *Notifications*) omarchy-toggle-notification-silencing ;;
    *Bar*) omarchy-toggle-waybar ;;
    *Layout*) omarchy-hyprland-workspace-layout-toggle ;;
    *Ratio*) omarchy-hyprland-window-single-square-aspect-toggle ;;
    *Gaps*) omarchy-hyprland-window-gaps-toggle ;;
    *Scaling*) omarchy-hyprland-monitor-scaling-cycle ;;
    *"Direct Boot"*) present_terminal omarchy-config-direct-boot ;;
    *"Passwordless Sudo"*) present_terminal omarchy-sudo-passwordless ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_hardware_menu() {
  local options="󰛧  Laptop Display\n 󰍹  Mirror Display"

  if omarchy-hw-hybrid-gpu; then
    options="$options\n  Hybrid GPU"
  fi

  if omarchy-hw-touchpad; then
    options="$options\n󰟸  Touchpad"
  fi

  if omarchy-hw-dell-xps-haptic-touchpad && omarchy-cmd-present dell-xps-touchpad-haptics; then
    options="$options\n󰌌  Touchpad Haptics"
  fi

  if omarchy-hw-touchscreen; then
    options="$options\n󰆽  Touchscreen"
  fi

  case $(menu "Toggle" "$options") in
    *Laptop*) omarchy-hyprland-monitor-internal toggle ;;
    *Mirror*) omarchy-hyprland-monitor-internal-mirror toggle ;;
    *Haptics*) show_hardware_touchpad_haptics_menu ;;
    *Touchpad*) omarchy-toggle-touchpad ;;
    *Touchscreen*) omarchy-toggle-touchscreen ;;
    *"Hybrid GPU"*) present_terminal omarchy-toggle-hybrid-gpu ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_hardware_touchpad_haptics_menu() {
  local current
  current=$(dell-xps-touchpad-haptics get)
  local selected
  selected=$(menu "Touchpad Haptics" "low\nmid\nhigh" "" "$current")

  if [[ -n $selected ]]; then
    dell-xps-touchpad-haptics set "$selected"
  else
    back_to show_hardware_menu
  fi
}
