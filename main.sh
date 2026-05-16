#!/bin/bash
# omarchy:summary=Launch the Omarchy Menu or takes a parameter to jump straight to a submenu.

# Source library files
source "$(dirname "$0")/lib/core.sh"
source "$(dirname "$0")/lib/menu.sh"
source "$(dirname "$0")/lib/navigation.sh"

# Source module files
source "$(dirname "$0")/modules/apps.sh"
source "$(dirname "$0")/modules/learn.sh"
source "$(dirname "$0")/modules/trigger.sh"
source "$(dirname "$0")/modules/style.sh"
source "$(dirname "$0")/modules/setup.sh"
source "$(dirname "$0")/modules/install.sh"
source "$(dirname "$0")/modules/remove.sh"
source "$(dirname "$0")/modules/update.sh"
source "$(dirname "$0")/modules/about.sh"
source "$(dirname "$0")/modules/system.sh"

# Source extensions AFTER modules so user overrides take effect
source "$(dirname "$0")/lib/extensions.sh"

# Define show_main_menu
show_main_menu() {
  local choice
  choice=$(menu "Go" "󰀻 Apps\n󰧑 Learn\n󱓞 Trigger\n Style\n Setup\n󰉉 Install\n󰭌 Remove\n Update\n About\n System")
  go_to_menu "$choice"
}

toggle_existing_menu

if [[ -n $1 ]]; then
  BACK_TO_EXIT=true
  go_to_menu "$1"
else
  show_main_menu
fi
