#!/bin/bash
# Window manager abstraction — hyprland, sway
# Sources: lib/platform.sh (for detect_wm)

wm_lock() {
  case "$(detect_wm)" in
    hyprland)
      if command -v hyprlock >/dev/null 2>&1; then hyprlock; return; fi
      ;;
    sway)
      if command -v swaylock >/dev/null 2>&1; then swaylock; return; fi
      ;;
  esac
  loginctl lock-session 2>/dev/null
}

wm_logout() {
  case "$(detect_wm)" in
    hyprland) hyprctl dispatch exit 2>/dev/null && return ;;
    sway) swaymsg exit 2>/dev/null && return ;;
  esac
  loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null
}

wm_gaps_toggle() {
  case "$(detect_wm)" in
    hyprland)
      local current
      current=$(hyprctl getoption general:gaps_in -j 2>/dev/null | jq -r '.int // 5' 2>/dev/null || echo "5")
      if ((current > 0)); then
        hyprctl keyword general:gaps_in 0 2>/dev/null
        hyprctl keyword general:gaps_out 0 2>/dev/null
        notify-send "Gaps" "No gaps"
      else
        hyprctl keyword general:gaps_in 5 2>/dev/null
        hyprctl keyword general:gaps_out 8 2>/dev/null
        notify-send "Gaps" "Default gaps"
      fi
      ;;
    sway)
      local current
      current=$(swaymsg -t get_tree 2>/dev/null | jq -r '.. | select(.type? == "output") | .current_mode.width' 2>/dev/null | head -1)
      swaymsg gaps inner current 0 2>/dev/null && notify-send "Gaps" "Toggled"
      ;;
    *) notify-send -u critical "Gaps" "Not supported on this WM" ;;
  esac
}

wm_floating_toggle() {
  case "$(detect_wm)" in
    hyprland)
      hyprctl dispatch togglefloating 2>/dev/null
      notify-send "Window" "Toggled floating"
      ;;
    sway)
      swaymsg floating toggle 2>/dev/null
      notify-send "Window" "Toggled floating"
      ;;
    *) notify-send -u critical "Floating" "Not supported on this WM" ;;
  esac
}

wm_bar_toggle() {
  if pgrep -x waybar >/dev/null 2>&1; then
    killall waybar
    notify-send "Bar" "Hidden"
  else
    waybar &
    notify-send "Bar" "Shown"
  fi
}

wm_restart() {
  case "$(detect_wm)" in
    hyprland) hyprctl reload 2>/dev/null ;;
    sway) swaymsg reload 2>/dev/null ;;
    *) notify-send -u critical "Restart" "Not supported on this WM" ;;
  esac
}

wm_config_dir() {
  case "$(detect_wm)" in
    hyprland) echo "$HOME/.config/hypr" ;;
    sway) echo "$HOME/.config/sway" ;;
    *) echo "$HOME/.config" ;;
  esac
}

wm_config_file() {
  local name="$1"
  case "$(detect_wm)" in
    hyprland) echo "$(wm_config_dir)/${name}.conf" ;;
    sway) echo "$(wm_config_dir)/config" ;;
    *) echo "" ;;
  esac
}