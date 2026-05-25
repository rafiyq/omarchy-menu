# Plan: Native Submenu Refactor (COMPLETED)

## Architecture

Walker/Elephant **natively support submenus and back-navigation** via two fields:

| Field | Where | Purpose |
|---|---|---|
| `SubMenu = "name"` | Entry | Walker switches to `menus:name` when selected |
| `Parent = "name"` | Menu | Elephant exposes `menus:parent` action for back navigation |

No custom controller, no file IPC, no polling.

## Structure

```
elephant-menus/
├── lib/
│   └── utils.lua              ← shared library
├── menus/
│   ├── top-level.lua          ← main menu (SubMenu entries + leaf entries)
│   ├── system.lua             ← Parent="top-level", Action="%VALUE%"
│   ├── style.lua              ← Parent="top-level", SubMenu for external + leaf
│   ├── setup.lua              ← Parent="top-level", SubMenu for external + leaf
│   ├── install.lua            ← Parent="top-level", Action="%VALUE%"
│   ├── remove.lua             ← Parent="top-level", Action="%VALUE%"
│   ├── update.lua             ← Parent="top-level", Action="%VALUE%"
│   ├── capture.lua            ← Parent="top-level", Action="%VALUE%"
│   ├── trigger.lua            ← Parent="top-level", Action="%VALUE%"
│   ├── walker.lua             ← Parent="top-level", Action="%VALUE%" NEW
│   └── elephant.lua           ← Parent="top-level", Action="%VALUE%" NEW
```

## How Navigation Works

### top-level.lua (hub)
```lua
{ Text = "System", SubMenu = "system" }       -- navigates to menus:system
{ Text = "Walker", SubMenu = "walker" }       -- navigates to menus:walker
{ Text = "About",  Value = "omarchy-launch-about" }  -- direct execution
{ Text = "Apps",   Value = "walker --provider desktopapplications -p Launch..." }
```

### Leaf providers (child)
```lua
Name = "system"
Parent = "top-level"      -- back button → returns to top-level
Action = "%VALUE%"        -- entries execute directly
```

### User experience
```
walker --provider menus:top-level
  → Select "System" → Walker shows menus:system (with back button)
  → Select "Lock" → command executes
  → Press back/Escape → returns to top-level
```

### Key decisions

1. **SubMenu (capital M)** — the Lua field is `SubMenu` (not `submenu`). Elephant's gopher-lua bridge reads `RawGetString("SubMenu")`.
2. **Parent** — setting `Parent = "top-level"` on sub-menus enables the `menus:parent` action. Walker's `previous` keybind triggers it.
3. **No controller** — `bin/elephant-menu` deleted. Just `walker --provider menus:top-level`.
4. **External submenus** — omarchythemes, powerprofiles, etc. don't have `Parent` set (we don't control them). They work as standalone pickers — no back navigation, but that's inherent to their design.
5. **Apps entry** — desktopapplications is a separate Elephant provider (not a menus submenu). Uses `Value = "walker --provider desktopapplications -p Launch..."` with `Action = "%VALUE%"` to spawn a nested Walker.
