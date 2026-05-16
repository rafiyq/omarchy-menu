#!/bin/bash
# Learning resources menu functions

show_learn_menu() {
  case $(menu "Learn" "  Keybindings\n  Omarchy\n  Hyprland\n󰣇  Arch\n  Neovim\n󱆃  Bash") in
    *Keybindings*) omarchy-menu-keybindings ;;
    *Omarchy*) omarchy-launch-webapp "https://learn.omacom.io/2/the-omarchy-manual" ;;
    *Hyprland*) omarchy-launch-webapp "https://wiki.hypr.land/" ;;
    *Arch*) omarchy-launch-webapp "https://wiki.archlinux.org/title/Main_page" ;;
    *Bash*) omarchy-launch-webapp "https://devhints.io/bash" ;;
    *Neovim*) omarchy-launch-webapp "https://www.lazyvim.org/keymaps" ;;
    *) back_to show_main_menu ;;
  esac
}
