Name = "setup"
NamePretty = "Setup"
Icon = "preferences-system"
FixedOrder = true
HideFromProviderlist = false
Cache = false

Parent = "start"

Action = "%VALUE%"

-- Self-contained path: place utils.lua alongside menu providers
local function find_utils_path()
    local paths = {
        os.getenv("HOME") .. "/.config/elephant/lib/utils.lua",
        os.getenv("HOME") .. "/.local/share/elephant-menus/lib/utils.lua",
    }
    for _, p in ipairs(paths) do
        local f = io.open(p, "r")
        if f then
            f:close()
            return p
        end
    end
    local source = debug.getinfo(1, "S").source
    if source:sub(1, 1) == "@" then
        source = source:sub(2)
    end
    local dir = source:match("(.*/)")
    if dir then
        local dev = dir .. "../lib/utils.lua"
        local f = io.open(dev, "r")
        if f then
            f:close()
            return dev
        end
    end
    return nil
end

function GetEntries()
    local entries = {}
    local utils_path = find_utils_path()
    local home = os.getenv("HOME")

    -- Helper for lua -e commands referencing utils
    local function lua_cmd(fn, ...)
        if ... then
            return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "(\"" .. table.concat({...}, "\", \"") .. "\")'"
        end
        return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "()'"
    end

    -- Audio (open pavucontrol or fallback)
    table.insert(entries, {
        Text = "Audio",
        Subtext = "Configure sound devices",
        Icon = "audio-card",
        Value = "pavucontrol &",
    })

    -- Wifi (open nm-connection-editor or fallback)
    table.insert(entries, {
        Text = "Wifi",
        Subtext = "Manage network connections",
        Icon = "network-wireless",
        Value = "nm-connection-editor &",
    })

    -- Bluetooth
    table.insert(entries, {
        Text = "Bluetooth",
        Subtext = "Pair Bluetooth devices",
        Icon = "bluetooth",
        Value = "blueberry &",
    })

    -- Power Profile (via walker sub-menu)
    table.insert(entries, {
        Text = "Power Profile",
        Subtext = "Select power mode",
        Icon = "battery",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:powerprofiles --width 300 --minheight 200\")'",
    })

    -- Monitors
    table.insert(entries, {
        Text = "Monitors",
        Subtext = "Configure display settings",
        Icon = "display",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/monitors.conf\")' && notify-send 'Monitors' 'Restart Hyprland to apply changes'",
    })

    -- Keybindings
    table.insert(entries, {
        Text = "Keybindings",
        Subtext = "View/modify shortcuts",
        Icon = "input-keyboard",
        Value = lua_cmd("menu_keybindings"),
    })

    -- Input
    table.insert(entries, {
        Text = "Input",
        Subtext = "Configure input devices",
        Icon = "input-mouse",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/input.conf\")'",
    })

    -- Defaults
    table.insert(entries, {
        Text = "Defaults",
        Subtext = "Reset to defaults",
        Icon = "preferences-desktop-default",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:defaults\")'",
    })

    -- DNS
    table.insert(entries, {
        Text = "DNS",
        Subtext = "Configure name servers",
        Icon = "network-workgroup",
        Value = lua_cmd("setup_dns"),
    })

    -- Security
    table.insert(entries, {
        Text = "Security",
        Subtext = "Security & firewall",
        Icon = "security-high",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:security\")'",
    })

    -- Config: Hyprland
    table.insert(entries, {
        Text = "Config: Hyprland",
        Subtext = "Edit Hyprland config",
        Icon = "hyprland",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprland.conf\")' && hyprctl reload",
    })

    -- Config: Hypridle
    table.insert(entries, {
        Text = "Config: Hypridle",
        Subtext = "Edit Hypridle config",
        Icon = "hyprland",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hypridle.conf\")' && systemctl --user restart hypridle",
    })

    -- Config: Hyprlock
    table.insert(entries, {
        Text = "Config: Hyprlock",
        Subtext = "Edit Hyprlock config",
        Icon = "system-lock-screen",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprlock.conf\")'",
    })

    -- Config: Hyprsunset
    table.insert(entries, {
        Text = "Config: Hyprsunset",
        Subtext = "Edit Hyprsunset config",
        Icon = "weather-clear-night",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprsunset.conf\")' && systemctl --user restart hyprsunset",
    })

    -- Config: SwayOSD
    table.insert(entries, {
        Text = "Config: SwayOSD",
        Subtext = "Edit SwayOSD config",
        Icon = "preferences-desktop-notifications",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/swayosd/config.toml\")' && systemctl --user restart swayosd",
    })

    -- Config: Walker
    table.insert(entries, {
        Text = "Config: Walker",
        Subtext = "Edit Walker config",
        Icon = "preferences-system-search",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/walker/config.toml\")' && m.restart_walker()",
    })

    -- Config: Waybar
    table.insert(entries, {
        Text = "Config: Waybar",
        Subtext = "Edit Waybar config",
        Icon = "panel",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/waybar/config.jsonc\")' && systemctl --user restart waybar",
    })

    return entries
end
