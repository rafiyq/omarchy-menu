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
    table.insert(entries, {
        Text = "Set Reminder",
        Subtext = "Create new reminder",
        Icon = "appointment-new",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.set_reminder(60, \"Reminder\")'",
    })
    table.insert(entries, {
        Text = "Show Reminders",
        Subtext = "List all reminders",
        Icon = "view-calendar",
        Value = lua_cmd("show_reminders"),
    })
    table.insert(entries, {
        Text = "Clear Reminders",
        Subtext = "Delete all reminders",
        Icon = "edit-clear",
        Value = lua_cmd("clear_reminders"),
    })

    -- Share
    table.insert(entries, {
        Text = "Share Clipboard",
        Subtext = "Copy between devices",
        Icon = "edit-paste",
        Value = lua_cmd("share_clipboard"),
    })

    -- Toggles
    table.insert(entries, {
        Text = "Toggle Screensaver",
        Subtext = "Enable/disable screensaver",
        Icon = "preferences-desktop-screensaver",
        Value = lua_cmd("toggle_screensaver"),
    })
    table.insert(entries, {
        Text = "Toggle Nightlight",
        Subtext = "Enable/disable blue light filter",
        Icon = "weather-clear-night",
        Value = lua_cmd("toggle_nightlight"),
    })
    table.insert(entries, {
        Text = "Toggle Idle Lock",
        Subtext = "Enable/disable auto-lock",
        Icon = "system-lock-screen",
        Value = lua_cmd("toggle_idle_lock"),
    })
    table.insert(entries, {
        Text = "Toggle Notifications",
        Subtext = "Enable/disable notifications",
        Icon = "notification-disabled",
        Value = lua_cmd("toggle_notifications"),
    })
    table.insert(entries, {
        Text = "Toggle Top Bar",
        Subtext = "Show/hide waybar",
        Icon = "panel",
        Value = lua_cmd("toggle_waybar"),
    })
    table.insert(entries, {
        Text = "Toggle Workspace Layout",
        Subtext = "Switch layout mode",
        Icon = "view-grid",
        Value = lua_cmd("toggle_workspace_layout"),
    })
    table.insert(entries, {
        Text = "Toggle Window Gaps",
        Subtext = "Show/hide window gaps",
        Icon = "window-new",
        Value = lua_cmd("toggle_window_gaps"),
    })
    table.insert(entries, {
        Text = "Toggle 1-Window Ratio",
        Subtext = "Toggle maximized only",
        Icon = "view-fullscreen",
        Value = lua_cmd("toggle_window_ratio"),
    })
    table.insert(entries, {
        Text = "Toggle Monitor Scaling",
        Subtext = "Cycle scaling factor",
        Icon = "display",
        Value = lua_cmd("cycle_monitor_scaling"),
    })

    return entries
end
