#!/bin/bash
# System setup and configuration menu functions

show_setup_menu() {
  local options="  Audio\n  Wifi\n󰂯  Bluetooth\n󱐋  Power Profile\n  System Sleep\n󰍹  Monitors"
  [[ -f ~/.config/hypr/bindings.conf ]] && options="$options\n  Keybindings"
  [[ -f ~/.config/hypr/input.conf ]] && options="$options\n  Input"
  options="$options\n  Defaults\n󰱔  DNS\n  Security\n  Config"

  case $(menu "Setup" "$options") in
    *Audio*) omarchy-launch-audio ;;
    *Wifi*) omarchy-launch-wifi ;;
    *Bluetooth*) omarchy-launch-bluetooth ;;
    *Power*) show_setup_power_menu ;;
    *System*) show_setup_system_menu ;;
    *Monitors*) open_in_editor ~/.config/hypr/monitors.conf ;;
    *Keybindings*) open_in_editor ~/.config/hypr/bindings.conf ;;
    *Input*) open_in_editor ~/.config/hypr/input.conf ;;
    *Defaults*) show_setup_default_menu ;;
    *DNS*) present_terminal omarchy-setup-dns ;;
    *Security*) show_setup_security_menu ;;
    *Config*) show_setup_config_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_setup_power_menu() {
  local profile
  profile=$(menu "Power Profile" "$(omarchy-powerprofiles-list)" "" "$(powerprofilesctl get)")

  if [[ "$profile" == "CNCLD" || -z "$profile" ]]; then
    back_to show_setup_menu
  else
    powerprofilesctl set "$profile"
  fi
}

show_setup_security_menu() {
  case $(menu "Setup" "󰈷 Fingerprint\n Fido2") in
    *Fingerprint*) present_terminal omarchy-setup-security-fingerprint ;;
    *Fido2*) present_terminal omarchy-setup-security-fido2 ;;
    *) back_to show_setup_menu ;;
  esac
}

show_setup_default_menu() {
  case $(menu "Default" " Browser\n Terminal\n Editor") in
    *Browser*) show_setup_default_browser_menu ;;
    *Terminal*) show_setup_default_terminal_menu ;;
    *Editor*) show_setup_default_editor_menu ;;
    *) back_to show_setup_menu ;;
  esac
}

show_setup_default_menu() {
  case $(menu "Default" "  Browser\n  Terminal\n  Editor") in
    *Browser*) show_setup_default_browser_menu ;;
    *Terminal*) show_setup_default_terminal_menu ;;
    *Editor*) show_setup_default_editor_menu ;;
    *) show_setup_menu ;;
  esac
}

browser_desktop_exists() {
  [[ -f ~/.local/share/applications/"$1" || -f ~/.nix-profile/share/applications/"$1" || -f /usr/share/applications/"$1" ]]
}

show_setup_default_browser_menu() {
  local options=""
  browser_desktop_exists chromium.desktop && options="$options  Chromium"
  browser_desktop_exists google-chrome.desktop && options="${options:+$options\n}󰊯  Chrome"
  browser_desktop_exists brave-browser.desktop && options="${options:+$options\n}󰖟  Brave"
  browser_desktop_exists brave-origin-beta.desktop && options="${options:+$options\n}󰖟  Brave Origin"
  browser_desktop_exists microsoft-edge.desktop && options="${options:+$options\n}󰇩  Edge"
  browser_desktop_exists firefox.desktop && options="${options:+$options\n}󰈹  Firefox"
  browser_desktop_exists zen.desktop && options="${options:+$options\n}󰖟  Zen"

  local current=""
  case "$(omarchy-default-browser)" in
    chromium) current="  Chromium" ;;
    chrome) current="󰊯  Chrome" ;;
    brave) current="󰖟  Brave" ;;
    brave-origin) current="󰖟  Brave Origin" ;;
    edge) current="󰇩  Edge" ;;
    firefox) current="󰈹  Firefox" ;;
    zen) current="󰖟  Zen" ;;
  esac

  case $(menu "Default Browser" "$options" "" "$current") in
    *Chromium*) omarchy-default-browser chromium ;;
    *Chrome*) omarchy-default-browser chrome ;;
    *"Brave Origin"*) omarchy-default-browser brave-origin ;;
    *Brave*) omarchy-default-browser brave ;;
    *Edge*) omarchy-default-browser edge ;;
    *Firefox*) omarchy-default-browser firefox ;;
    *Zen*) omarchy-default-browser zen ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_default_terminal_menu() {
  local options=""
  omarchy-cmd-present alacritty && options="$options  Alacritty"
  omarchy-cmd-present foot && options="${options:+$options\n}  Foot"
  omarchy-cmd-present ghostty && options="${options:+$options\n}  Ghostty"
  omarchy-cmd-present kitty && options="${options:+$options\n}  Kitty"

  local current=""
  case "$(omarchy-default-terminal)" in
    alacritty) current="  Alacritty" ;;
    foot) current="  Foot" ;;
    ghostty) current="  Ghostty" ;;
    kitty) current="  Kitty" ;;
  esac

  case $(menu "Default Terminal" "$options" "" "$current") in
    *Alacritty*) omarchy-default-terminal alacritty ;;
    *Foot*) omarchy-default-terminal foot ;;
    *Ghostty*) omarchy-default-terminal ghostty ;;
    *Kitty*) omarchy-default-terminal kitty ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_default_editor_menu() {
  local options=""
  omarchy-cmd-present nvim && options="$options  Neovim"
  omarchy-cmd-present code && options="${options:+$options\n}  VSCode"
  omarchy-cmd-present cursor && options="${options:+$options\n}  Cursor"
  omarchy-cmd-present zeditor && options="${options:+$options\n}  Zed"
  omarchy-cmd-present sublime_text && options="${options:+$options\n}  Sublime Text"
  omarchy-cmd-present helix && options="${options:+$options\n}  Helix"
  omarchy-cmd-present vim && options="${options:+$options\n}  Vim"
  omarchy-cmd-present emacs && options="${options:+$options\n}  Emacs"

  local current=""
  case "$(omarchy-default-editor)" in
    nvim) current="  Neovim" ;;
    code) current="  VSCode" ;;
    cursor) current="  Cursor" ;;
    zed | zeditor) current="  Zed" ;;
    sublime_text) current="  Sublime Text" ;;
    helix) current="  Helix" ;;
    vim) current="  Vim" ;;
    emacs) current="  Emacs" ;;
  esac

  case $(menu "Default Editor" "$options" "" "$current") in
    *Neovim*) omarchy-default-editor nvim ;;
    *VSCode*) omarchy-default-editor code ;;
    *Cursor*) omarchy-default-editor cursor ;;
    *Zed*) omarchy-default-editor zed ;;
    *Sublime*) omarchy-default-editor sublime_text ;;
    *Helix*) omarchy-default-editor helix ;;
    *Vim*) omarchy-default-editor vim ;;
    *Emacs*) omarchy-default-editor emacs ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_config_menu() {
  case $(menu "Setup" "  Hyprland\n  Hypridle\n  Hyprlock\n  Hyprsunset\n  Swayosd\n󰌧  Walker\n󰍜  Waybar\n󰞅  XCompose") in
    *Hyprland*) open_in_editor ~/.config/hypr/hyprland.conf ;;
    *Hypridle*) open_in_editor ~/.config/hypr/hypridle.conf && omarchy-restart-hypridle ;;
    *Hyprlock*) open_in_editor ~/.config/hypr/hyprlock.conf ;;
    *Hyprsunset*) open_in_editor ~/.config/hypr/hyprsunset.conf && omarchy-restart-hyprsunset ;;
    *Swayosd*) open_in_editor ~/.config/swayosd/config.toml && omarchy-restart-swayosd ;;
    *Walker*) open_in_editor ~/.config/walker/config.toml && omarchy-restart-walker ;;
    *Waybar*) open_in_editor ~/.config/waybar/config.jsonc && omarchy-restart-waybar ;;
    *XCompose*) open_in_editor ~/.XCompose && omarchy-restart-xcompose ;;
    *) back_to show_setup_menu ;;
  esac
}

show_setup_system_menu() {
  local options=""

  if omarchy-toggle-enabled suspend-off; then
    options="$options󰒲  Enable Suspend"
  else
    options="$options󰒲  Disable Suspend"
  fi

  if omarchy-hibernation-available; then
    options="$options\n󰤁  Disable Hibernate"
  else
    options="$options\n󰤁  Enable Hibernate"
  fi

  case $(menu "System" "$options") in
    *Suspend*) omarchy-toggle-suspend ;;
    *"Enable Hibernate"*) present_terminal omarchy-hibernation-setup ;;
    *"Disable Hibernate"*) present_terminal omarchy-hibernation-remove ;;
    *) back_to show_setup_menu ;;
  esac
}
