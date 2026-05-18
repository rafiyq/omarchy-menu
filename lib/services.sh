#!/bin/bash
# System service operations — launch, restart, toggle, defaults, etc.
# Sources: lib/platform.sh, lib/pkg.sh, lib/wm.sh

# Terminal detection (shared helper)
_detect_terminal() {
  local t
  for t in foot kitty alacritty ghostty wezterm; do
    command -v "$t" >/dev/null 2>&1 && { echo "$t"; return; }
  done
  hostname 2>/dev/null
  echo ""
}

_run_in_terminal() {
  local term
  term=$(_detect_terminal)
  if [[ -n "$term" ]]; then
    "$term" "$@" &
  elif command -v xdg-terminal-exec >/dev/null 2>&1; then
    xdg-terminal-exec -- "$@"
  else
    echo "Error: no terminal found" >&2
    return 1
  fi
}

# About – system info
launch_about() {
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  else
    uname -a
  fi
}

# System services
launch_audio() {
  if command -v pavucontrol >/dev/null 2>&1; then
    pavucontrol &
  else
    notify-send -u critical "Audio" "pavucontrol is not installed"
    return 1
  fi
}

launch_bluetooth() {
  if command -v blueberry >/dev/null 2>&1; then
    blueberry &
  elif command -v bluedevil-wizard >/dev/null 2>&1; then
    bluedevil-wizard &
  elif command -v bluetoothctl >/dev/null 2>&1; then
    bluetoothctl
  else
    notify-send -u critical "Bluetooth" "No Bluetooth manager found"
    return 1
  fi
}

launch_wifi() {
  if command -v nm-connection-editor >/dev/null 2>&1; then
    nm-connection-editor &
  else
    notify-send -u critical "Wi-Fi" "nm-connection-editor is not installed"
    return 1
  fi
}

launch_screensaver() {
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

launch_walker() {
  if command -v walker >/dev/null 2>&1; then
    walker "$@"
  else
    notify-send -u critical "Walker" "walker is not installed"
    return 1
  fi
}

launch_webapp() {
  xdg-open "$1" 2>/dev/null || {
    notify-send -u critical "Open" "Cannot open $1"
    return 1
  }
}

# Config
config_direct_boot() {
  sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  notify-send "Direct Boot" "GRUB timeout set to 0"
}

sudo_passwordless() {
  local target="/etc/sudoers.d/passwordless"
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee "$target" >/dev/null
  sudo chmod 440 "$target"
  notify-send "Passwordless Sudo" "Enabled for wheel group"
}

# Default app management
default_browser() {
  if [[ -z "${1:-}" ]]; then
    xdg-settings get default-web-browser 2>/dev/null | sed 's/\.desktop$//'
    return
  fi
  local desktop
  case "$1" in
    chromium) desktop="chromium.desktop" ;; chrome) desktop="google-chrome.desktop" ;;
    brave) desktop="brave-browser.desktop" ;; brave-origin) desktop="brave-origin-beta.desktop" ;;
    edge) desktop="microsoft-edge.desktop" ;; firefox) desktop="firefox.desktop" ;;
    zen) desktop="zen.desktop" ;; *) desktop="$1.desktop" ;;
  esac
  xdg-settings set default-web-browser "$desktop" 2>/dev/null
  notify-send "Default Browser" "Set to $1"
}

default_terminal() {
  if [[ -z "${1:-}" ]]; then
    xdg-mime query default x-scheme-handler/terminal 2>/dev/null | sed 's/\.desktop$//'
    return
  fi
  local desktop
  case "$1" in
    alacritty) desktop="Alacritty.desktop" ;; foot) desktop="foot.desktop" ;;
    ghostty) desktop="ghostty.desktop" ;; kitty) desktop="kitty.desktop" ;;
    *) desktop="$1.desktop" ;;
  esac
  xdg-mime default "$desktop" x-scheme-handler/terminal 2>/dev/null
  notify-send "Default Terminal" "Set to $1"
}

default_editor() {
  if [[ -z "${1:-}" ]]; then
    xdg-mime query default text/plain 2>/dev/null | sed 's/\.desktop$//'
    return
  fi
  local desktop
  case "$1" in
    nvim) desktop="nvim.desktop" ;; code) desktop="code.desktop" ;;
    cursor) desktop="cursor-bin.desktop" ;; zed) desktop="zed.desktop" ;;
    sublime_text) desktop="sublime-text-4.desktop" ;; helix) desktop="helix.desktop" ;;
    vim) desktop="vim.desktop" ;; emacs) desktop="emacs.desktop" ;;
    *) desktop="$1.desktop" ;;
  esac
  xdg-mime default "$desktop" text/plain 2>/dev/null
  notify-send "Default Editor" "Set to $1"
}

# Font management
font_list() { fc-list : family 2>/dev/null | sed 's/,.*//' | sort -u | head -50; }

font_current() {
  local conf
  conf=$(wm_config_dir)/looknfeel.conf
  grep -oP 'font\.name=\K.*' "$conf" 2>/dev/null || echo ""
}

font_set() {
  local conf
  conf=$(wm_config_dir)/looknfeel.conf
  if [[ -f "$conf" ]]; then
    sed -i "s/font\.name=.*/font.name=$1/" "$conf"
    notify-send "Font" "Set to $1"
  else
    notify-send -u critical "Font" "No looknfeel.conf found"
    return 1
  fi
}

# Hibernation
hibernation_available() { [[ -f /sys/power/state ]] && grep -q disk /sys/power/state 2>/dev/null; }

hibernation_setup() {
  if ! hibernation_available; then
    notify-send -u critical "Hibernation" "Not available"
    return 1
  fi
  local swap_size swap_target
  swap_size=$(free -g | awk '/Mem:/ {print $2 + 2}')
  swap_target="/swapfile"
  if [[ ! -f "$swap_target" ]]; then
    sudo fallocate -l "${swap_size}G" "$swap_target"
    sudo chmod 600 "$swap_target"
    sudo mkswap "$swap_target"
  fi
  if ! swapon --show | grep -q "$swap_target"; then sudo swapon "$swap_target"; fi
  if ! grep -q "$swap_target" /etc/fstab; then
    echo "$swap_target none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
  fi
  notify-send "Hibernation" "Setup complete. Reboot to activate."
}

hibernation_remove() {
  if [[ -f /swapfile ]] && swapon --show | grep -q /swapfile; then sudo swapoff /swapfile; fi
  sudo sed -i '\|^/swapfile|d' /etc/fstab
  notify-send "Hibernation" "Removed. Reboot to finalize."
}

# Input
menu_input() {
  local prompt="${1:-Input}"
  local backend
  backend=$(get_menu_backend 2>/dev/null)
  [[ -z "$backend" ]] && backend="rofi"
  case "$backend" in
    rofi) if command -v rofi >/dev/null 2>&1; then
      rofi -dmenu -p "$prompt"
      return
    fi ;;
    walker) if command -v walker >/dev/null 2>&1; then
      walker --dmenu -p "$prompt"
      return
    fi ;;
    tui)
      printf '\033[1;36m%s\033[0m ' "$prompt"
      local _val
      read -r _val
      echo "$_val"
      return
      ;;
  esac
  local _val
  read -rp "$prompt: " _val
  echo "$_val"
}

menu_keybindings() {
  local kb
  case "$(detect_wm)" in
    hyprland) kb="$(wm_config_dir)/bindings.conf" ;;
    sway) kb="$(wm_config_dir)/config" ;;
    *) kb="" ;;
  esac
  if [[ -f "$kb" ]]; then
    _run_in_terminal "${EDITOR:-nvim}" "$kb"
  else
    notify-send "Keybindings" "No keybindings config found"
  fi
}

# Notifications
notification_send() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  else
    echo "Notification: $*"
  fi
}

# Power profiles
powerprofiles_list() {
  if command -v powerprofilesctl >/dev/null 2>&1; then
    powerprofilesctl list 2>/dev/null
  else
    printf "%s\n" "balanced" "performance" "power-saver"
  fi
}

# Reminders
reminder() {
  local remind_dir
  remind_dir="$(wmenu_data_dir)/reminders"
  mkdir -p "$remind_dir"
  case "${1:-}" in
    show)
      if [[ -z "$(ls "$remind_dir" 2>/dev/null)" ]]; then
        notify-send "Reminders" "No active reminders"
      else
        for f in "$remind_dir"/*; do
          [[ -f "$f" ]] && notify-send "Reminder" "$(cat "$f")"
        done
      fi
      ;;
    clear)
      rm -f "$remind_dir"/*
      notify-send "Reminders" "All reminders cleared"
      ;;
    *)
      local minutes="${1:-}" message="${2:-Reminder}"
      if [[ ! "$minutes" =~ ^[0-9]+$ ]] || ((minutes <= 0)); then
        notify-send -u critical "Reminder" "Invalid minutes: $minutes"
        return 1
      fi
      local seconds=$((minutes * 60))
      echo "$message" >"$remind_dir/$$_${minutes}m"
      (sleep "$seconds" && notify-send "Reminder" "$message" && rm -f "$remind_dir/$$_${minutes}m") &
      notify-send "Reminder" "Set for ${minutes} minutes: $message"
      ;;
  esac
}

# Convenience install/remove wrappers (distro-aware via pkg.sh)
install_browser() {
  local pkg
  pkg=$(pkg_name "$1")
  pkg_thirdparty_install "$pkg"
}

install_gaming_steam() { pkg_install steam; }
install_gaming_retroarch() { pkg_install retroarch; }
install_gaming_minecraft() { pkg_thirdparty_install "$(pkg_name minecraft)"; }
install_gaming_geforce_now() { pkg_thirdparty_install "$(pkg_name geforce-now)"; }
install_gaming_xbox_cloud() { pkg_thirdparty_install "$(pkg_name xbox-cloud)"; }
install_gaming_xbox_controllers() { pkg_thirdparty_install "$(pkg_name xpadneo)"; }
install_gaming_lutris() { pkg_install lutris; }
install_gaming_heroic() { pkg_thirdparty_install "$(pkg_name heroic)"; }
install_gaming_moonlight() { pkg_install "$(pkg_name moonlight)"; }

install_dropbox() { pkg_thirdparty_install "$(pkg_name dropbox)"; }
install_nordvpn() { pkg_thirdparty_install "$(pkg_name nordvpn)"; }
install_tailscale() {
  pkg_install "$(pkg_name tailscale)" && sudo systemctl enable --now tailscaled
}
install_helix() { pkg_install helix; }
install_vscode() { pkg_thirdparty_install "$(pkg_name code)"; }
install_zed() { pkg_thirdparty_install "$(pkg_name zed)"; }
install_terminal() { pkg_install "$1"; }

remove_browser() {
  local pkg
  pkg=$(pkg_name "$1")
  pkg_remove "$pkg"
}

remove_gaming_steam() { pkg_remove steam; }
remove_gaming_retroarch() { pkg_remove retroarch; }
remove_gaming_minecraft() { pkg_remove "$(pkg_name minecraft)"; }
remove_gaming_geforce_now() { pkg_remove "$(pkg_name geforce-now)"; }
remove_gaming_xbox_cloud() { pkg_remove "$(pkg_name xbox-cloud)"; }
remove_gaming_xbox_controllers() { pkg_remove "$(pkg_name xpadneo)"; }
remove_gaming_moonlight() { pkg_remove "$(pkg_name moonlight)"; }
remove_gaming_lutris() { pkg_remove lutris; }
remove_gaming_heroic() { pkg_remove "$(pkg_name heroic)"; }

remove_security_fingerprint() {
  local user="${USER:-$(whoami)}"
  if command -v fprintd-list >/dev/null 2>&1; then
    sudo fprintd-delete "$user" 2>/dev/null
    notify-send "Security" "Fingerprint data removed"
  else
    notify-send -u critical "Security" "fprintd is not installed"
    return 1
  fi
}

# Service restarts
restart_hypridle() { systemctl --user restart hypridle 2>/dev/null || killall -HUP hypridle 2>/dev/null; }
restart_hyprsunset() { systemctl --user restart hyprsunset 2>/dev/null || killall -HUP hyprsunset 2>/dev/null; }
restart_mako() { systemctl --user restart mako 2>/dev/null || { killall mako 2>/dev/null; mako & }; }
restart_swayosd() { systemctl --user restart swayosd 2>/dev/null || { killall swayosd 2>/dev/null; swayosd & }; }
restart_walker() { systemctl --user restart walker 2>/dev/null || { killall walker 2>/dev/null; walker & }; }
restart_waybar() { systemctl --user restart waybar 2>/dev/null || { killall waybar 2>/dev/null; waybar & }; }
restart_pipewire() { systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null; }
restart_wifi() { sudo systemctl restart NetworkManager 2>/dev/null; }
restart_bluetooth() { sudo systemctl restart bluetooth 2>/dev/null; }

# Setup
setup_dns() {
  if command -v nmtui >/dev/null 2>&1; then
    _run_in_terminal nmtui
  else
    notify-send -u critical "DNS Setup" "nmtui is not available"
    return 1
  fi
}

setup_security_fingerprint() {
  if command -v fprintd-enroll >/dev/null 2>&1; then
    _run_in_terminal fprintd-enroll
  else
    notify-send -u critical "Security" "fprintd is not installed"
    return 1
  fi
}

# System power
system_reboot() { systemctl reboot; }
system_shutdown() { systemctl poweroff; }
system_suspend() { systemctl suspend; }
system_hibernate() { systemctl hibernate; }

toggles_flag_dir() {
  local d
  d="$(wmenu_data_dir)/toggles"
  mkdir -p "$d"
  echo "$d"
}

toggle_enabled() {
  [[ -f "$(toggles_flag_dir)/$1" ]]
}

toggle_screensaver() {
  if systemctl --user is-active hypridle >/dev/null 2>&1; then
    systemctl --user stop hypridle
    notify-send "Screensaver" "Disabled"
  else
    systemctl --user start hypridle
    notify-send "Screensaver" "Enabled"
  fi
}

toggle_nightlight() {
  if pgrep -x hyprsunset >/dev/null 2>&1; then
    killall hyprsunset
    notify-send "Nightlight" "Disabled"
  else
    hyprsunset -t 4500 &
    notify-send "Nightlight" "Enabled (4500K)"
  fi
}

toggle_idle() {
  if systemctl --user is-active hypridle >/dev/null 2>&1; then
    systemctl --user stop hypridle
    notify-send "Idle Lock" "Disabled"
  else
    systemctl --user start hypridle
    notify-send "Idle Lock" "Enabled"
  fi
}

toggle_notification_silencing() {
  if pgrep -x mako >/dev/null 2>&1; then
    makoctl mode -a do-not-disturb 2>/dev/null
    notify-send "Notifications" "Silenced"
  else
    makoctl mode -r do-not-disturb 2>/dev/null
    notify-send "Notifications" "Unsilenced"
  fi
}

toggle_touchpad() {
  case "$(detect_wm)" in
    hyprland)
      local state
      state=$(hyprctl getoption input:touchpad:enabled -j 2>/dev/null | jq -r '.int // 1' 2>/dev/null || echo "1")
      if ((state)); then
        hyprctl keyword input:touchpad:enabled false 2>/dev/null
        notify-send "Touchpad" "Disabled"
      else
        hyprctl keyword input:touchpad:enabled true 2>/dev/null
        notify-send "Touchpad" "Enabled"
      fi
      ;;
    *)
      notify-send -u critical "Touchpad" "Not supported on this WM"
      return 1
      ;;
  esac
}

toggle_hybrid_gpu() {
  if command -v optimus-manager >/dev/null 2>&1; then
    sudo optimus-manager --switch hybrid --no-confirm
  elif command -v envycontrol >/dev/null 2>&1; then
    sudo envycontrol -s hybrid
  else
    notify-send -u critical "Hybrid GPU" "optimus-manager or envycontrol required"
    return 1
  fi
}

toggle_suspend() {
  local flag_file
  flag_file="$(toggles_flag_dir)/suspend-off"
  if [[ -f "$flag_file" ]]; then
    rm -f "$flag_file"
    notify-send "Suspend" "Enabled"
  else
    touch "$flag_file"
    notify-send "Suspend" "Disabled"
  fi
}

# Updates
update_firmware() {
  if command -v fwupdmgr >/dev/null 2>&1; then
    _run_in_terminal fwupdmgr update
  else
    notify-send -u critical "Firmware" "fwupd is not installed"
    return 1
  fi
}

update_time() { sudo timedatectl set-ntp true && notify-send "Time" "NTP sync enabled"; }

tz_select() { _run_in_terminal tzselect; }
