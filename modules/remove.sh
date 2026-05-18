#!/bin/bash
# Removal menus functions

show_remove_menu() {
  case $(menu "Remove" "󰣇  Package\n  Browser\n  Gaming\n  Security") in
    *Package*) terminal pkg_remove ;;
    *Browser*) show_remove_browser_menu ;;
    *Gaming*) show_remove_gaming_menu ;;
    *Security*) show_remove_security_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_remove_security_menu() {
  case $(menu "Remove" "󰈷 Fingerprint") in
    *Fingerprint*) present_terminal remove_security_fingerprint ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_browser_menu() {
  case $(menu "Remove Browser" " Chrome\n Edge\n Brave\n Brave Origin\n Firefox\n󰖟 Zen") in
    *Chrome*) present_terminal "remove_browser chrome" ;;
    *Edge*) present_terminal "remove_browser edge" ;;
    *"Brave Origin"*) present_terminal "remove_browser brave-origin" ;;
    *Brave*) present_terminal "remove_browser brave" ;;
    *Firefox*) present_terminal "remove_browser firefox" ;;
    *Zen*) present_terminal "remove_browser zen" ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_gaming_menu() {
  case $(menu "Remove Gaming" " Steam\n RetroArch\n󰍳 Minecraft\n󰢹 NVIDIA GeForce NOW\n Xbox Cloud Gaming\n󰂯 Xbox Controller\n󰍹 Moonlight\n Lutris\n󱓟 Heroic") in
    *Steam*) present_terminal remove_gaming_steam ;;
    *RetroArch*) present_terminal remove_gaming_retroarch ;;
    *Minecraft*) present_terminal remove_gaming_minecraft ;;
    *GeForce*) present_terminal remove_gaming_geforce_now ;;
    *"Xbox Cloud"*) present_terminal remove_gaming_xbox_cloud ;;
    *Xbox*) present_terminal remove_gaming_xbox_controllers ;;
    *Moonlight*) present_terminal remove_gaming_moonlight ;;
    *Lutris*) present_terminal remove_gaming_lutris ;;
    *Heroic*) present_terminal remove_gaming_heroic ;;
    *) back_to show_remove_menu ;;
  esac
}
