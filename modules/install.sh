#!/bin/bash
# Installation menus functions

show_install_menu() {
  case $(menu "Install" "󰣇  Package\n󰣇  AUR/Third-party\n  Editor\n  Terminal\n  Browser\n󱚤  AI\n  Gaming\n  Services") in
    *Package*) terminal pkg_install_interactive ;;
    *AUR*) terminal pkg_thirdparty_install ;;
    *Editor*) show_install_editor_menu ;;
    *Terminal*) show_install_terminal_menu ;;
    *Browser*) show_install_browser_menu ;;
    *Gaming*) show_install_gaming_menu ;;
    *AI*) show_install_ai_menu ;;
    *Services*) show_install_service_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_install_browser_menu() {
  case $(menu "Install Browser" " Chrome\n Edge\n Brave\n Brave Origin\n Firefox\n󰖟 Zen") in
    *Chrome*) present_terminal "install_browser chrome" ;;
    *Edge*) present_terminal "install_browser edge" ;;
    *"Brave Origin"*) present_terminal "install_browser brave-origin" ;;
    *Brave*) present_terminal "install_browser brave" ;;
    *Firefox*) present_terminal "install_browser firefox" ;;
    *Zen*) present_terminal "install_browser zen" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_service_menu() {
  case $(menu "Install Service" " Dropbox\n Tailscale\n󱇱 NordVPN\n󰟵 Bitwarden") in
    *Dropbox*) present_terminal install_dropbox ;;
    *Tailscale*) present_terminal install_tailscale ;;
    *NordVPN*) present_terminal install_nordvpn ;;
    *Bitwarden*) install_and_launch "Bitwarden" "bitwarden" "bitwarden" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_editor_menu() {
  case $(menu "Install Editor" " VSCode\n Cursor\n Zed\n Sublime Text\n Helix\n Vim\n Emacs") in
    *VSCode*) present_terminal install_vscode ;;
    *Cursor*) install_and_launch "Cursor" "cursor" "cursor" ;;
    *Zed*) present_terminal install_zed ;;
    *Sublime*) install_and_launch "Sublime Text" "sublime" "sublime_text" ;;
    *Helix*) present_terminal install_helix ;;
    *Vim*) install "Vim" "vim" ;;
    *Emacs*) install "Emacs" "emacs" && systemctl --user enable --now emacs.service ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_terminal_menu() {
  case $(menu "Install Terminal" " Alacritty\n Foot\n Ghostty\n Kitty") in
    *Alacritty*) install_terminal "alacritty" ;;
    *Foot*) install_terminal "foot" ;;
    *Ghostty*) install_terminal "ghostty" ;;
    *Kitty*) install_terminal "kitty" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_ai_menu() {
  local ollama_pkg
  if command -v nvidia-smi >/dev/null 2>&1; then
    ollama_pkg="ollama-cuda"
  elif command -v rocminfo >/dev/null 2>&1; then
    ollama_pkg="ollama-rocm"
  else
    ollama_pkg="ollama"
  fi

  case $(menu "Install AI" "󱚤 LM Studio\n󱚤 Ollama\n󱚤 Crush") in
    *Studio*) install "LM Studio" "lmstudio" ;;
    *Ollama*) install "Ollama" "$ollama_pkg" ;;
    *Crush*) install "Crush" "crush" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_gaming_menu() {
  case $(menu "Install Gaming" " Steam\n RetroArch\n󰍳 Minecraft\n󰢹 NVIDIA GeForce NOW\n Xbox Cloud Gaming\n󰂯 Xbox Controller\n󰍹 Moonlight\n Lutris\n󱓟 Heroic") in
    *Steam*) present_terminal install_gaming_steam ;;
    *RetroArch*) present_terminal install_gaming_retroarch ;;
    *Minecraft*) install_and_launch "Minecraft" "minecraft" "minecraft-launcher" ;;
    *GeForce*) present_terminal install_gaming_geforce_now ;;
    *"Xbox Cloud"*) present_terminal install_gaming_xbox_cloud ;;
    *Xbox*) present_terminal install_gaming_xbox_controllers ;;
    *Lutris*) present_terminal install_gaming_lutris ;;
    *Heroic*) present_terminal install_gaming_heroic ;;
    *Moonlight*) present_terminal install_gaming_moonlight ;;
    *) back_to show_install_menu ;;
  esac
}
