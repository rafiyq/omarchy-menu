# Omarchy Menu

A distro-agnostic, WM-agnostic hierarchical menu system for Linux desktops. Supports Arch/Debian/Fedora and Hyprland/Sway. Provides a modular menu for launching apps, configuring the system, installing software, and more.

Uses [walker](https://github.com/abceric/walker) (with native Elephant/Lua providers) as the menu backend. The `run` entry point auto-detects Walker and falls back to an error message (check out the `tui` branch for TTY/SSH scenarios).

## Project Structure

```
omarchy-menu/
├── run                  # Entry point — launches walker --provider menus:start
├── Makefile             # lint (shellcheck + luacheck), test (smoke), fmt targets
├── .luacheckrc          # Luacheck configuration for Lua providers
├── menus/              # Native Elephant Lua providers (flat directory)
│   ├── start.lua       # Main entry point
│   ├── system.lua      # Lock, suspend, hibernate, logout, reboot, shutdown
│   ├── style.lua       # Theme, font, background, Hyprland look & feel, screensaver, about
│   ├── setup.lua       # Audio, wifi, bluetooth, power profile, monitors, keybindings, config editors
│   ├── install.lua     # Packages, AUR, web apps, browsers, editors, terminals, AI, gaming, dev environments
│   ├── remove.lua      # Remove software
│   ├── update.lua      # System updates, channel switch, themes, firmware
│   ├── capture.lua     # Screenshots, screenrecord, OCR, color picker
│   └── trigger.lua     # Reminders, share, toggles (screensaver, nightlight, idle lock, notifications, waybar, etc.)
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
# Launch the start menu (requires walker + display)
./run

# Or invoke walker directly
walker --provider menus:start
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

2. **Bash TUI on `tui` Branch**
   - `lib/tui.sh` lives on the `tui` branch.
   - `run` only launches `walker --provider menus:":start"`.
   - Future migration to a Lua TUI is possible.

3. **Inlined Utilities**
   - Configurable paths via `XDG_*` environment variables.
   - Package manager scripts (pkg_install, pkg_remove, update_system) detect distro and call pacman/apt/dnf directly.
   
## Branches

- `run` — Walker + Elephant Lua providers (default)
- `tui` — Bash TUI fallback kept for TTY/SSH scenarios

To switch to the TUI branch:
```bash
git checkout tui
```
