#!/bin/bash
# Platform detection — distro and window manager
# No external dependencies beyond bash

detect_distro() {
  local id id_like
  id=$(awk -F= '/^ID=/{print $2}' /etc/os-release 2>/dev/null | tr -d '"' | tr '[:upper:]' '[:lower:]')
  id_like=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release 2>/dev/null | tr -d '"' | tr '[:upper:]' '[:lower:]')

  case "$id" in
    arch | artix | manjaro | endeavouros | cachyos | garuda)
      echo "arch"
      return
      ;;
    debian | ubuntu | linuxmint | pop | elementary | zorin | kali | raspbian)
      echo "debian"
      return
      ;;
    fedora | rhel | centos | rockylinux | almalinux | nobara)
      echo "fedora"
      return
      ;;
  esac

  [[ "$id_like" == *"arch"* ]] && { echo "arch"; return; }
  [[ "$id_like" == *"debian"* ]] && { echo "debian"; return; }
  [[ "$id_like" == *"fedora"* ]] || [[ "$id_like" == *"rhel"* ]] && { echo "fedora"; return; }

  echo ""
}

detect_wm() {
  local desktop
  desktop="${XDG_CURRENT_DESKTOP:-}"

  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && { echo "hyprland"; return; }
  [[ -n "${SWAYSOCK:-}" ]] && { echo "sway"; return; }

  case "${desktop,,}" in
    *hyprland*) echo "hyprland"; return ;;
    *sway*) echo "sway"; return ;;
  esac

  echo ""
}

wmenu_config_dir() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/wmenu"
}

wmenu_data_dir() {
  echo "${XDG_DATA_HOME:-$HOME/.local/share}/wmenu"
}

# Hardware detection
hw_hybrid_gpu() {
  local gpu_count
  gpu_count=$(lspci -nn | grep -c '\[030[02]\]' 2>/dev/null || echo 0)
  ((gpu_count >= 2))
}

hw_touchpad() { grep -qE 'touchpad|trackpad' /proc/bus/input/devices 2>/dev/null; }

hw_touchscreen() { grep -qiE 'touchscreen' /proc/bus/input/devices 2>/dev/null; }