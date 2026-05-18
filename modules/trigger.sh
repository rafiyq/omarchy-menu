#!/bin/bash
# Trigger actions menu functions (reminders, capture, toggles)

show_trigger_menu() {
  case $(menu "Trigger" "󰔛  Reminder\n  Capture\n󰔎  Toggle\n  Hardware") in
    *Reminder*) show_reminder_menu ;;
    *Capture*) show_capture_menu ;;
    *Toggle*) show_toggle_menu ;;
    *Hardware*) show_hardware_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_reminder_menu() {
  case $(menu "Reminder" "󰔛  Set one\n󰔛  Show all\n󰔛  Clear all") in
    *Set*) show_custom_reminder_input ;;
    *"Show all"*) reminder show ;;
    *"Clear all"*) reminder clear ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_custom_reminder_input() {
  local minutes
  minutes=$(menu_input "Remind in minutes")

  if [[ $minutes =~ ^[0-9]+$ ]] && ((minutes > 0)); then
    show_reminder_message_input "$minutes"
  elif [[ -n $minutes ]]; then
    notification_send "󰔛" "Invalid reminder" "Enter the number of minutes" -u critical
    show_custom_reminder_input
  else
    back_to show_reminder_menu
  fi
}

show_reminder_message_input() {
  local minutes="$1"
  local message
  message=$(menu_input "Reminder message")

  if [[ -n $message ]]; then
    reminder "$minutes" "$message"
  else
    reminder "$minutes"
  fi
}

show_capture_menu() {
  case $(menu "Capture" "  Screenshot\n  Screenrecord\n󰴑  Text Extraction\n󰃉  Color") in
    *Screenshot*) capture_screenshot ;;
    *Screenrecord*) show_screenrecord_menu ;;
    *Text*) capture_text_extraction ;;
    *Color*) capture_colorpick ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_screenrecord_menu() {
  capture_screenrecording --stop-recording && exit 0

  case $(menu "Screenrecord" "  With no audio\n  With desktop audio\n  With desktop + microphone audio\n  With desktop + microphone audio + webcam") in
    *"With no audio") capture_screenrecording ;;
    *"With desktop audio") capture_screenrecording --with-desktop-audio ;;
    *"With desktop + microphone audio") capture_screenrecording --with-desktop-audio --with-microphone-audio ;;
    *"With desktop + microphone audio + webcam")
      local device
      device=$(show_webcam_select_menu) || {
        back_to show_capture_menu
        return
      }
      capture_screenrecording --with-desktop-audio --with-microphone-audio --with-webcam --webcam-device="$device"
      ;;
    *) back_to show_capture_menu ;;
  esac
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

show_toggle_menu() {
  local options="󱄄  Screensaver\n󰔎  Nightlight\n󱫖  Idle Lock\n󰂛  Notifications\n󰍜  Top Bar\n  Window Gaps\n  Direct Boot\n󰟵  Passwordless Sudo"

  case $(menu "Toggle" "$options") in
    *Screensaver*) toggle_screensaver ;;
    *Nightlight*) toggle_nightlight ;;
    *Idle*) toggle_idle ;;
    *Notifications*) toggle_notification_silencing ;;
    *Bar*) wm_bar_toggle ;;
    *Gaps*) wm_gaps_toggle ;;
    *"Direct Boot"*) present_terminal config_direct_boot ;;
    *"Passwordless Sudo"*) present_terminal sudo_passwordless ;;
    *) back_to show_trigger_menu ;;
  esac
}

show_hardware_menu() {
  local options=""

  if hw_hybrid_gpu; then
    options="  Hybrid GPU"
  fi

  if hw_touchpad; then
    options="${options:+$options\n}󰟸  Touchpad"
  fi

  if hw_touchscreen; then
    options="${options:+$options\n}󰆽  Touchscreen"
  fi

  if [[ -z "$options" ]]; then
    notify-send "Hardware" "No hardware-specific options available"
    back_to show_trigger_menu
    return
  fi

  case $(menu "Hardware" "$options") in
    *Touchpad*) toggle_touchpad ;;
    *"Hybrid GPU"*) present_terminal toggle_hybrid_gpu ;;
    *) back_to show_trigger_menu ;;
  esac
}
