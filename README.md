# Omarchy Menu

A hierarchical menu system for [Omarchy](https://learn.omacom.io/2/the-omarchy-manual) — an Arch Linux desktop environment built on Hyprland. Provides a modular, extensible menu for launching apps, configuring the system, installing software, and more.

Uses [walker](https://github.com/abceric/walker) or [rofi](https://github.com/davatorium/rofi) as the menu backend.

## Project Structure

```
omarchy-menu/
├── main.sh              # Entry point — sources libs and modules, defines main menu
├── Makefile             # lint, test, fmt, check targets
├── lib/
│   ├── core.sh          # Core utility functions (terminal, install, editor)
│   ├── menu.sh          # Menu display abstraction (walker/rofi backends)
│   ├── navigation.sh    # Menu routing and back navigation logic
│   └── extensions.sh    # User extension loading
└── modules/
    ├── apps.sh          # Application launching
    ├── learn.sh         # Learning resources (keybindings, wikis)
    ├── trigger.sh       # Quick actions (reminders, capture, toggles)
    ├── style.sh         # Theming, fonts, backgrounds
    ├── setup.sh         # System setup (audio, wifi, defaults, config)
    ├── install.sh       # Software installation menus
    ├── remove.sh        # Software removal menus
    ├── update.sh        # System updates, process restarts
    ├── about.sh         # About Omarchy information
    └── system.sh        # Power controls (lock, suspend, shutdown)
```

## Usage

```bash
# Launch the main menu
omarchy-menu

# Jump directly to a submenu
omarchy-menu apps
omarchy-menu style
omarchy-menu install
```

## Configuration

### Menu Backend

Set the menu backend via environment variable or config file:

```bash
# Environment variable
export OMARCHY_MENU_BACKEND=rofi

# Or config file at ~/.config/omarchy/menu.conf
MENU_BACKEND=walker
```

### User Extensions

Place custom overrides in `~/.config/omarchy/extensions/menu.sh`. This file is sourced after all modules, so you can override any menu function:

```bash
# Example: override the install menu
show_install_menu() {
  case $(menu "Install" "My Custom Option\n󰣇 Package") in
  *Custom*) my-custom-installer ;;
  *Package*) terminal omarchy-pkg-install ;;
  *) back_to show_main_menu ;;
  esac
}
```

## Development

### Prerequisites

- [shellcheck](https://github.com/koalaman/shellcheck) — Static analysis
- [shfmt](https://github.com/mvdan/sh) — Code formatting
- [bats-core](https://github.com/bats-core/bats-core) — Testing framework

### Make Targets

```bash
make lint     # Run shellcheck on all shell files
make test     # Run bats test suite
make fmt      # Auto-format all shell files with shfmt
make check    # Run lint + test
```

### Running Tests

```bash
bats tests/
```

### Adding a New Module

1. Create `modules/yourmodule.sh` with a `show_yourmodule_menu()` function
2. Add a menu entry in `main.sh`'s `show_main_menu()`
3. Add a routing case in `lib/navigation.sh`'s `go_to_menu()`
4. Source the module in `main.sh`
