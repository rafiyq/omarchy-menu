#!/bin/bash
# About information menu functions

show_about() {
  case $(menu "About" "󰋶 Omarchy\n󰧑 Version\n󱁶 Release Notes\n󰞋 Documentation\n󰍡 Report Bug") in
    *Omarchy*) omarchy-launch-about ;;
    *Version*) omarchy-launch-about version ;;
    *Release*) omarchy-launch-webapp "https://learn.omacom.io/2/the-omarchy-manual" ;;
    *Documentation*) omarchy-launch-webapp "https://learn.omacom.io/2/the-omarchy-manual" ;;
    *Bug*) omarchy-launch-webapp "https://github.com/basecamp/omarchy/issues" ;;
    *) back_to show_main_menu ;;
  esac
}
