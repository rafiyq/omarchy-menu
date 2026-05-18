#!/bin/bash
# Documentation resources menu functions

show_documentation_menu() {
  case $(menu "Documentation" "  Keybindings\n  Hyprland\n󰣇  Arch\n  Neovim\n󱆃  Bash\n󰞋  Documentation") in
    *Keybindings*) menu_keybindings ;;
    *Hyprland*) launch_webapp "https://wiki.hypr.land/" ;;
    *Arch*) launch_webapp "https://wiki.archlinux.org/" ;;
    *Neovim*) launch_webapp "https://www.lazyvim.org/keymaps" ;;
    *Bash*) launch_webapp "https://devhints.io/bash" ;;
    *Documentation*) launch_webapp "https://learn.omacom.io/2/the-omarchy-manual" ;;
    *) back_to show_main_menu ;;
  esac
}
