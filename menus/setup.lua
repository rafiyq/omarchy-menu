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
    entries[#entries + 1] = {
        Text = "Audio",
        Icon = "audio-card",
        Value = "pavucontrol &",
    }

    -- Wifi (open nm-connection-editor or fallback)
    entries[#entries + 1] = {
        Text = "Wifi",
        Icon = "network-wireless",
        Value = "nm-connection-editor &",
    }

    -- Bluetooth
    entries[#entries + 1] = {
        Text = "Bluetooth",
        Icon = "bluetooth",
        Value = "blueberry &",
    }

    -- Power Profile (via walker sub-menu)
    entries[#entries + 1] = {
        Text = "Power Profile",
        Icon = "battery",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:powerprofiles --width 300 --minheight 200\")'",
    }

    -- Monitors
    entries[#entries + 1] = {
        Text = "Monitors",
        Icon = "display",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/monitors.conf\")' && notify-send 'Monitors' 'Restart Hyprland to apply changes'",
    }

    -- Keybindings
    entries[#entries + 1] = {
        Text = "Keybindings",
        Icon = "input-keyboard",
        Value = lua_cmd("menu_keybindings"),
    }

    -- Input
    entries[#entries + 1] = {
        Text = "Input",
        Icon = "input-mouse",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/input.conf\")'",
    }

    -- Defaults
    entries[#entries + 1] = {
        Text = "Defaults",
        Icon = "preferences-desktop-default",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:defaults\")'",
    }

    -- DNS
    entries[#entries + 1] = {
        Text = "DNS",
        Icon = "network-workgroup",
        Value = lua_cmd("setup_dns"),
    }

    -- Security
    entries[#entries + 1] = {
        Text = "Security",
        Icon = "security-high",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:security\")'",
    }

    -- Config: Hyprland
    entries[#entries + 1] = {
        Text = "Config: Hyprland",
        Icon = "hyprland",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprland.conf\")' && hyprctl reload",
    }

    -- Config: Hypridle
    entries[#entries + 1] = {
        Text = "Config: Hypridle",
        Icon = "hyprland",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hypridle.conf\")' && systemctl --user restart hypridle",
    }

    -- Config: Hyprlock
    entries[#entries + 1] = {
        Text = "Config: Hyprlock",
        Icon = "system-lock-screen",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprlock.conf\")'",
    }

    -- Config: Hyprsunset
    entries[#entries + 1] = {
        Text = "Config: Hyprsunset",
        Icon = "weather-clear-night",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/hypr/hyprsunset.conf\")' && systemctl --user restart hyprsunset",
    }

    -- Config: SwayOSD
    entries[#entries + 1] = {
        Text = "Config: SwayOSD",
        Icon = "preferences-desktop-notifications",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/swayosd/config.toml\")' && systemctl --user restart swayosd",
    }

    -- Config: Walker
    entries[#entries + 1] = {
        Text = "Config: Walker",
        Icon = "preferences-system-search",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/walker/config.toml\")' && m.restart_walker()",
    }

    -- Config: Waybar
    entries[#entries + 1] = {
        Text = "Config: Waybar",
        Icon = "panel",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. home .. "/.config/waybar/config.jsonc\")' && systemctl --user restart waybar",
    }

    return entries
end
