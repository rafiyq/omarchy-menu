Name = "trigger"
NamePretty = "Trigger"
Icon = "preferences-system-notifications"
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
    local function lua_cmd(fn, ...)
        if ... then
            return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "(\"" .. table.concat({...}, "\", \"") .. "\")'"
        end
        return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "()'"
    end

    -- Reminders
    entries[#entries + 1] = {
        Text = "Set Reminder",
        Icon = "appointment-new",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.set_reminder(60, \"Reminder\")'",
    }
    entries[#entries + 1] = {
        Text = "Show Reminders",
        Icon = "view-calendar",
        Value = lua_cmd("show_reminders"),
    }
    entries[#entries + 1] = {
        Text = "Clear Reminders",
        Icon = "edit-clear",
        Value = lua_cmd("clear_reminders"),
    }

    -- Share
    entries[#entries + 1] = {
        Text = "Share Clipboard",
        Icon = "edit-paste",
        Value = lua_cmd("share_clipboard"),
    }

    -- Toggles
    entries[#entries + 1] = {
        Text = "Toggle Screensaver",
        Icon = "preferences-desktop-screensaver",
        Value = lua_cmd("toggle_screensaver"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Nightlight",
        Icon = "weather-clear-night",
        Value = lua_cmd("toggle_nightlight"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Idle Lock",
        Icon = "system-lock-screen",
        Value = lua_cmd("toggle_idle_lock"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Notifications",
        Icon = "notification-disabled",
        Value = lua_cmd("toggle_notifications"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Top Bar",
        Icon = "panel",
        Value = lua_cmd("toggle_waybar"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Workspace Layout",
        Icon = "view-grid",
        Value = lua_cmd("toggle_workspace_layout"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Window Gaps",
        Icon = "window-new",
        Value = lua_cmd("toggle_window_gaps"),
    }
    entries[#entries + 1] = {
        Text = "Toggle 1-Window Ratio",
        Icon = "view-fullscreen",
        Value = lua_cmd("toggle_window_ratio"),
    }
    entries[#entries + 1] = {
        Text = "Toggle Monitor Scaling",
        Icon = "display",
        Value = lua_cmd("cycle_monitor_scaling"),
    }

    return entries
end
