#!/bin/bash
# Styling options menu functions (fonts, etc.)

show_style_menu() {
  case $(menu "Style" " Font\n Config\n About") in
    *Font*) show_font_menu ;;
    *Config*) open_in_editor "$(wm_config_dir)/looknfeel.conf" ;;
    *About*) launch_about ;;
    *) back_to show_main_menu ;;
  esac
}

show_font_menu() {
  local theme
  theme=$(menu "Font" "$(font_list)" "--width 350" "$(font_current)")
  if [[ "$theme" == "CNCLD" || -z "$theme" ]]; then
    back_to show_style_menu
  else
    font_set "$theme"
  fi
}
