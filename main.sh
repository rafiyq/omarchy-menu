#!/bin/bash
# Main entry point
# Sources libraries and modules, defines main menu

# Source library files
source "$(dirname "$0")/lib/platform.sh"
source "$(dirname "$0")/lib/pkg.sh"
source "$(dirname "$0")/lib/wm.sh"
source "$(dirname "$0")/lib/capture.sh"
source "$(dirname "$0")/lib/services.sh"
source "$(dirname "$0")/lib/core.sh"
source "$(dirname "$0")/lib/tui.sh"
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

show_main_menu() {
  local choice
  choice=$(menu "Go" "󰀻 Apps\n  Trigger\n Style\n Setup\n󰉉 Install\n󰭌 Remove\n Update\n󰧑 Documentation\n About\n System")
  go_to_menu "$choice"
}

toggle_existing_menu

if [[ ${#@} -gt 0 ]]; then
  BACK_TO_EXIT=true
  go_to_menu "$1"
else
  show_main_menu
fi
