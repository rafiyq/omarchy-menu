# WMenu — Universal Desktop Menu

A distro-agnostic, WM-agnostic hierarchical menu system for Linux desktops. Supports Arch/Debian/Fedora and Hyprland/Sway. Provides a modular menu for launching apps, configuring the system, installing software, and more.

Uses [walker](https://github.com/abceric/walker) (with native Elephant/Lua providers) as the menu backend. The `main` entry point auto-detects Walker and falls back to an error message (check out the `tui` branch for TTY/SSH scenarios).

## Project Structure

```
wmenu/
├── main                 # Entry point — launches walker --provider menus:top-level
├── Makefile             # lint (shellcheck + luacheck), test (smoke), fmt targets
├── .luacheckrc           # Luacheck configuration for Lua providers
├── menus/               # Native Elephant Lua providers (flat top-level directory)
│   ├── top-level.lua   # Main entry point
│   ├── system.lua      # Lock, suspend, hibernate, logout, reboot, shutdown
│   ├── style.lua       # Theme, font, background, Hyprland look & feel, screensaver, about
│   ├── setup.lua       # Audio, wifi, bluetooth, power profile, monitors, keybindings, config editors
│   ├── install.lua     # Packages, AUR, web apps, browsers, editors, terminals, AI, gaming, dev environments
│   ├── remove.lua      # Remove software
│   ├── update.lua      # System updates, channel switch, themes, firmware
│   ├── capture.lua     # Screenshots, screenrecord, OCR, color picker
│   └── trigger.lua     # Reminders, share, toggles (screensaver, nightlight, idle lock, notifications, waybar, etc.)
├── lib/
│   ├── utils.lua        # Shared Lua library (no external dependencies)
│   └── menu.sh          # Bash menu display (walker/rofi/tui) — legacy, kept for reference
└── tests/
    ├── test-providers.lua # Smoke-test all menu providers
    └── test-utils.lua     # Smoke-test shared Lua library
```

## Usage

```bash
# Launch the main menu (requires walker + display)
./main

# Or invoke walker directly
walker --provider menus:top-level
```
wmenu/
├── main                 # Entry point — launches walker --provider menus:top-level or bash TUI fallback
├── Makefile             # lint (shellcheck + luacheck), test (smoke), fmt targets
├── .luacheckrc           # Luacheck configuration for Lua providers
├── menus/               # Native Elephant Lua providers (flat top-level directory)
│   ├── top-level.lua   # Main entry point (Apps, Trigger, Style, Setup, Install, Remove, Update, About, System)
│   ├── system.lua      # Lock, suspend, hibernate, logout, reboot, shutdown
│   ├── style.lua       # Theme, font, background, Hyprland look & feel, screensaver, about
│   ├── setup.lua       # Audio, wifi, bluetooth, power profile, monitors, keybindings, config editors
│   ├── install.lua     # Packages, AUR, web apps, browsers, editors, terminals, AI, gaming, dev environments
│   ├── remove.lua      # Remove software
│   ├── update.lua      # System updates, channel switch, themes, firmware
│   ├── capture.lua     # Screenshots, screenrecord, OCR, color picker
│   └── trigger.lua     # Reminders, share, toggles (screensaver, nightlight, idle lock, notifications, waybar, etc.)
├── lib/                 # Remaining bash utilities (kept for TUI fallback and shared logic)
│   ├── utils.lua        # Shared Lua library (lock, screenshot, reminders, toggles, etc.)
│   ├── core.sh          # Core utility functions (terminal, install, editor)
│   ├── menu.sh          # Menu display abstraction (walker/rofi/tui backends)
│   ├── tui.sh           # Pure bash TUI menu (no external dependencies)
│   ├── extensions.sh    # User extension loading
│   ├── platform.sh      # Distro/WM/hardware detection
│   ├── pkg.sh           # Package manager abstraction (pacman/apt/dnf)
│   ├── wm.sh            # Window manager operations (Hyprland/Sway)
│   ├── capture.sh       # Screenshot, recording, color pick
│   └── services.sh      # System services (power, audio, bluetooth, fonts, toggles)
└── tests/
    ├── test-providers.lua # Smoke-test all menu providers
    └── test-utils.lua     # Smoke-test shared Lua library
```

## Usage

```bash
# Launch the main menu (auto-detects walker, falls back to bash TUI)
./main

# With walker + display available, this is equivalent to:
walker --provider menus:top-level
```

## Configuration

### Menu Backend

Set the menu backend via environment variable (for bash TUI path):

```bash
export MENU_BACKEND=rofi   # or walker, tui
```

Available backends:
- `walker` — GUI menu launcher via native Elephant/Lua providers (preferred)
- `rofi` — GUI menu launcher (fallback)
- `tui` — Pure bash terminal UI with arrow keys (no dependencies)

If no backend is configured, the menu auto-detects: walker → rofi → tui.

### User Extensions

Place custom overrides in `~/.config/wmenu/extensions/menu.sh`. This file is sourced after all modules, so you can override any menu function:

```bash
# Example: override the install menu
show_install_menu() {
  # ...
}
```

## Development

### Prerequisites

- [shellcheck](https://github.com/koalaman/shellcheck) — Static analysis for bash
- [shfmt](https://github.com/mvdan/sh) — Code formatting for bash
- [luacheck](https://github.com/mpeterv/luacheck) — Static analysis for Lua

### Make Targets

```bash
make lint     # Run shellcheck + luacheck
make test     # Run Lua smoke tests
make fmt      # Auto-format shell files with shfmt
make check    # Run lint + test
```

### Running Tests

```bash
# Smoke tests (pure Lua, no external dependencies)
make test

# Or manually:
lua tests/test-providers.lua
lua tests/test-utils.lua
```

## Design Decisions

1. **Native Elephant/Lua Providers**
   - Menu definitions are pure Lua files in `menus/`.
   - No custom controller, no IPC, no polling.
   - Navigation uses Elephant's native `SubMenu`/`Parent` fields.

2. **Self-Contained**
   - All Lua code lives inside `omarchy-menu/`.
   - No external dependency on `elephant-menus`.
3. **Bash TUI on `tui` Branch**
   - `lib/tui.sh` lives on the `tui` branch.
   - `main` only launches `walker --provider menus:top-level`.
   - Future migration to a Lua TUI is possible.

4. **Inlined Utilities**
   - `lib/utils.lua` replaces `omarchy-*` bash scripts with pure Lua or thin wrappers.
   - Configurable paths via `XDG_*` environment variables.
   - Package manager scripts (pkg_install, pkg_remove, update_system) detect
distro and call pacman/apt/dnf directly, with optional `omarchy-*` wrapper
fallback when available.

## Branches

- `main` — Walker + Elephant Lua providers (default, TUI removed)
- `tui` — Bash TUI fallback kept for TTY/SSH scenarios

To switch to the TUI branch:
```bash
git checkout tui
```
