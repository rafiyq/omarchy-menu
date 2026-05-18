#!/bin/bash
# System setup and configuration menu functions

show_setup_menu() {
  local options="  Audio\n  Wifi\n󰂯  Bluetooth\n󱐋  Power Profile\n󰍹  Monitors"
  local kb_conf
  kb_conf=$(wm_config_dir)/bindings.conf
  [[ -f "$kb_conf" ]] && options="$options\n  Keybindings"
  local input_conf
  input_conf=$(wm_config_dir)/input.conf
  [[ -f "$input_conf" ]] && options="$options\n  Input"
  options="$options\n  Defaults\n󰱔  DNS\n  Security\n  Config"

  case $(menu "Setup" "$options") in
    *Audio*) launch_audio ;;
    *Wifi*) launch_wifi ;;
    *Bluetooth*) launch_bluetooth ;;
    *Power*) show_setup_power_menu ;;
    *Monitors*) open_in_editor "$(wm_config_dir)/monitors.conf" ;;
    *Keybindings*) open_in_editor "$kb_conf" ;;
    *Input*) open_in_editor "$input_conf" ;;
    *Defaults*) show_setup_default_menu ;;
    *DNS*) present_terminal setup_dns ;;
    *Security*) show_setup_security_menu ;;
    *Config*) show_setup_config_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_setup_power_menu() {
  local profile
  profile=$(menu "Power Profile" "$(powerprofiles_list)" "" "$(powerprofilesctl get 2>/dev/null)")

  if [[ "$profile" == "CNCLD" || -z "$profile" ]]; then
    back_to show_setup_menu
  else
    powerprofilesctl set "$profile"
  fi
}

show_setup_security_menu() {
  case $(menu "Setup" "󰈷 Fingerprint") in
    *Fingerprint*) present_terminal setup_security_fingerprint ;;
    *) back_to show_setup_menu ;;
  esac
}

show_setup_default_menu() {
  case $(menu "Default" "  Browser\n  Terminal\n  Editor") in
    *Browser*) show_setup_default_browser_menu ;;
    *Terminal*) show_setup_default_terminal_menu ;;
    *Editor*) show_setup_default_editor_menu ;;
    *) back_to show_setup_menu ;;
  esac
}

browser_desktop_exists() {
  [[ -f ~/.local/share/applications/"$1" || -f ~/.nix-profile/share/applications/"$1" || -f /usr/share/applications/"$1" ]]
}

show_setup_default_browser_menu() {
  local options=""
  browser_desktop_exists chromium.desktop && options="  Chromium"
  browser_desktop_exists google-chrome.desktop && options="${options:+$options\n}󰊯  Chrome"
  browser_desktop_exists brave-browser.desktop && options="${options:+$options\n}󰖟  Brave"
  browser_desktop_exists brave-origin-beta.desktop && options="${options:+$options\n}󰖟  Brave Origin"
  browser_desktop_exists microsoft-edge.desktop && options="${options:+$options\n}󰇩  Edge"
  browser_desktop_exists firefox.desktop && options="${options:+$options\n}󰈹  Firefox"
  browser_desktop_exists zen.desktop && options="${options:+$options\n}󰖟  Zen"

  local current=""
  case "$(default_browser)" in
    chromium) current="  Chromium" ;;
    chrome) current="󰊯  Chrome" ;;
    brave) current="󰖟  Brave" ;;
    brave-origin) current="󰖟  Brave Origin" ;;
    edge) current="󰇩  Edge" ;;
    firefox) current="󰈹  Firefox" ;;
    zen) current="󰖟  Zen" ;;
  esac

  case $(menu "Default Browser" "$options" "" "$current") in
    *Chromium*) default_browser chromium ;;
    *Chrome*) default_browser chrome ;;
    *"Brave Origin"*) default_browser brave-origin ;;
    *Brave*) default_browser brave ;;
    *Edge*) default_browser edge ;;
    *Firefox*) default_browser firefox ;;
    *Zen*) default_browser zen ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_default_terminal_menu() {
  local options=""
  command -v alacritty >/dev/null && options="  Alacritty"
  command -v foot >/dev/null && options="${options:+$options\n}  Foot"
  command -v ghostty >/dev/null && options="${options:+$options\n}  Ghostty"
  command -v kitty >/dev/null && options="${options:+$options\n}  Kitty"

  local current=""
  case "$(default_terminal)" in
    alacritty) current="  Alacritty" ;;
    foot) current="  Foot" ;;
    ghostty) current="  Ghostty" ;;
    kitty) current="  Kitty" ;;
  esac

  case $(menu "Default Terminal" "$options" "" "$current") in
    *Alacritty*) default_terminal alacritty ;;
    *Foot*) default_terminal foot ;;
    *Ghostty*) default_terminal ghostty ;;
    *Kitty*) default_terminal kitty ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_default_editor_menu() {
  local options=""
  command -v nvim >/dev/null && options="  Neovim"
  command -v code >/dev/null && options="${options:+$options\n}  VSCode"
  command -v cursor >/dev/null && options="${options:+$options\n}  Cursor"
  command -v zed >/dev/null && options="${options:+$options\n}  Zed"
  command -v sublime_text >/dev/null && options="${options:+$options\n}  Sublime Text"
  command -v helix >/dev/null && options="${options:+$options\n}  Helix"
  command -v vim >/dev/null && options="${options:+$options\n}  Vim"
  command -v emacs >/dev/null && options="${options:+$options\n}  Emacs"

  local current=""
  case "$(default_editor)" in
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
    *Neovim*) default_editor nvim ;;
    *VSCode*) default_editor code ;;
    *Cursor*) default_editor cursor ;;
    *Zed*) default_editor zed ;;
    *Sublime*) default_editor sublime_text ;;
    *Helix*) default_editor helix ;;
    *Vim*) default_editor vim ;;
    *Emacs*) default_editor emacs ;;
    *) back_to show_setup_default_menu ;;
  esac
}

show_setup_config_menu() {
  local wm
  wm=$(detect_wm)
  case "$wm" in
    hyprland)
      case $(menu "Setup" "  Hyprland\n  Hypridle\n  Hyprlock\n  Hyprsunset\n  Swayosd\n󰌧  Walker\n󰍜  Waybar\n󰞅  XCompose") in
        *Hyprland*) open_in_editor "$(wm_config_dir)/hyprland.conf" ;;
        *Hypridle*) open_in_editor "$(wm_config_dir)/hypridle.conf" && restart_hypridle ;;
        *Hyprlock*) open_in_editor "$(wm_config_dir)/hyprlock.conf" ;;
        *Hyprsunset*) open_in_editor "$(wm_config_dir)/hyprsunset.conf" && restart_hyprsunset ;;
        *Swayosd*) open_in_editor ~/.config/swayosd/config.toml && restart_swayosd ;;
        *Walker*) open_in_editor ~/.config/walker/config.toml && restart_walker ;;
        *Waybar*) open_in_editor ~/.config/waybar/config.jsonc && restart_waybar ;;
        *XCompose*) open_in_editor ~/.XCompose ;;
        *) back_to show_setup_menu ;;
      esac
      ;;
    sway)
      case $(menu "Setup" " Swayosd\n󰌧  Walker\n󰍜  Waybar") in
        *Swayosd*) open_in_editor ~/.config/swayosd/config.toml && restart_swayosd ;;
        *Walker*) open_in_editor ~/.config/walker/config.toml && restart_walker ;;
        *Waybar*) open_in_editor ~/.config/waybar/config.jsonc && restart_waybar ;;
        *) back_to show_setup_menu ;;
      esac
      ;;
    *)
      notify-send "Config" "No recognized window manager detected"
      back_to show_setup_menu
      ;;
  esac
}

show_setup_system_menu() {
  local options=""

  if toggle_enabled suspend-off; then
    options="󰒲  Enable Suspend"
  else
    options="󰒲  Disable Suspend"
  fi

  if hibernation_available; then
    options="$options\n󰤁  Disable Hibernate"
  else
    options="$options\n󰤁  Enable Hibernate"
  fi

  case $(menu "System" "$options") in
    *Suspend*) toggle_suspend ;;
    *"Enable Hibernate"*) present_terminal hibernation_setup ;;
    *"Disable Hibernate"*) present_terminal hibernation_remove ;;
    *) back_to show_setup_menu ;;
  esac
}
