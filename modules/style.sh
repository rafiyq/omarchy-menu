#!/bin/bash
# Styling options menu functions (themes, fonts, etc.)

show_style_menu() {
  case $(menu "Style" "󰸌 Theme\n󰟵 Unlock\n Font\n Background\n Hyprland\n󱄄 Screensaver\n About") in
    *Theme*) show_theme_menu ;;
    *Unlock*) omarchy-launch-walker -m menus:omarchyunlocks --width 800 --minheight 400 ;;
    *Font*) show_font_menu ;;
    *Background*) show_background_menu ;;
    *Hyprland*) open_in_editor ~/.config/hypr/looknfeel.conf ;;
    *Screensaver*) show_screensaver_menu ;;
    *About*) show_style_about_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_style_about_menu() {
  case $(menu "About" " Edit Text\n Set From Image\n Restore Default") in
    *Text*) omarchy-branding-about text ;;
    *Image*) omarchy-branding-about image ;;
    *Default*) omarchy-branding-about reset ;;
    *) back_to show_style_menu ;;
  esac
}

show_screensaver_menu() {
  case $(menu "Screensaver" " Edit Text\n Set From Image\n Restore Default") in
    *Text*) omarchy-branding-screensaver text ;;
    *Image*) omarchy-branding-screensaver image ;;
    *Default*) omarchy-branding-screensaver reset ;;
    *) back_to show_style_menu ;;
  esac
}

show_theme_menu() {
  omarchy-launch-walker -m menus:omarchythemes --width 800 --minheight 400
}

show_background_menu() {
  omarchy-launch-walker -m menus:omarchyBackgroundSelector --width 800 --minheight 400
}

show_font_menu() {
  local theme
  theme=$(menu "Font" "$(omarchy-font-list)" "--width 350" "$(omarchy-font-current)")
  if [[ "$theme" == "CNCLD" || -z "$theme" ]]; then
    back_to show_style_menu
  else
    omarchy-font-set "$theme"
  fi
}

show_about_menu() {
  case $(menu "About" "  Edit Text\n  Set From Image\n  Restore Default") in
    *Text*) omarchy-branding-about text ;;
    *Image*) omarchy-branding-about image ;;
    *Default*) omarchy-branding-about reset ;;
    *) show_style_menu ;;
  esac
}

show_screensaver_menu() {
  case $(menu "Screensaver" "  Edit Text\n  Set From Image\n  Restore Default") in
    *Text*) omarchy-branding-screensaver text ;;
    *Image*) omarchy-branding-screensaver image ;;
    *Default*) omarchy-branding-screensaver reset ;;
    *) show_style_menu ;;
  esac
}

show_theme_menu() {
  omarchy-launch-walker -m menus:omarchythemes --width 800 --minheight 400
}

show_background_menu() {
  omarchy-launch-walker -m menus:omarchyBackgroundSelector --width 800 --minheight 400
}

show_font_menu() {
  theme=$(menu "Font" "$(omarchy-font-list)" "--width 350" "$(omarchy-font-current)")
  if [[ $theme == "CNCLD" || -z $theme ]]; then
    back_to show_style_menu
  else
    omarchy-font-set "$theme"
  fi
}
