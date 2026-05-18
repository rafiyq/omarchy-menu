#!/bin/bash
# Capture functions — screenshot, recording, text extraction, color pick
# Wayland only (wlroots-based compositors)

capture_screenshot() {
  if ! command -v grim >/dev/null 2>&1; then
    notify-send -u critical "Screenshot" "grim is not installed"
    return 1
  fi
  local target
  target="${SCREENSHOT_DIR:-$HOME/Pictures}/screenshot_$(date +%Y%m%d_%H%M%S).png"
  if command -v slurp >/dev/null 2>&1; then
    grim -g "$(slurp)" "$target" && wl-copy <"$target" && notify-send "Screenshot" "Saved and copied to clipboard"
  else
    grim "$target" && wl-copy <"$target" && notify-send "Screenshot" "Full screen saved and copied"
  fi
}

capture_text_extraction() {
  if ! command -v grim >/dev/null 2>&1 || ! command -v tesseract >/dev/null 2>&1; then
    notify-send -u critical "Text Extraction" "grim and tesseract are required"
    return 1
  fi
  local text
  text=$(grim -g "$(slurp)" - | tesseract -l eng - - 2>/dev/null)
  if [[ -n "$text" ]]; then
    echo -n "$text" | wl-copy && notify-send "Text Extraction" "Copied to clipboard"
  else
    notify-send -u critical "Text Extraction" "No text detected"
    return 1
  fi
}

capture_screenrecording() {
  if ! command -v wf-recorder >/dev/null 2>&1; then
    notify-send -u critical "Screen Recording" "wf-recorder is not installed"
    return 1
  fi
  if [[ "${1:-}" == "--stop-recording" ]]; then
    if pgrep -f wf-recorder >/dev/null; then
      pkill -SIGINT wf-recorder
      notify-send "Screen Recording" "Recording stopped"
    fi
    return 0
  fi
  local output
  output="${SCREENRECORD_DIR:-$HOME/Videos}/recording_$(date +%Y%m%d_%H%M%S).mp4"
  local audio_args=()
  for arg in "$@"; do
    case "$arg" in
      --with-desktop-audio) audio_args+=(-a) ;;
      --with-microphone-audio) audio_args+=(-a "$(pactl get-default-source)") ;;
      --with-webcam) ;;
      --webcam-device=*) ;;
    esac
  done
  wf-recorder "${audio_args[@]}" -f "$output" &
  notify-send "Screen Recording" "Recording started: $output"
}

capture_colorpick() {
  if command -v hyprpicker >/dev/null 2>&1; then
    hyprpicker -a
  else
    notify-send -u critical "Color Picker" "hyprpicker is not installed"
    return 1
  fi
}

# List webcam devices for screen recording
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