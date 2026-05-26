Name = "system"
NamePretty = "System"
Icon = "system-shutdown"
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
    local function lua_cmd(fn)
        return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "()'"
    end

    table.insert(entries, {
        Text = "Screensaver",
        Subtext = "Start screensaver",
        Icon = "preferences-desktop-screensaver",
        Value = lua_cmd("launch_screensaver"),
    })
    table.insert(entries, {
        Text = "Lock",
        Subtext = "Lock screen now",
        Icon = "system-lock-screen",
        Value = lua_cmd("lock_screen"),
    })
    table.insert(entries, {
        Text = "Suspend",
        Subtext = "Suspend to RAM",
        Icon = "system-suspend",
        Value = lua_cmd("suspend"),
    })
    table.insert(entries, {
        Text = "Hibernate",
        Subtext = "Suspend to disk",
        Icon = "system-hibernate",
        Value = lua_cmd("hibernate"),
    })
    table.insert(entries, {
        Text = "Logout",
        Subtext = "Log out of session",
        Icon = "system-log-out",
        Value = lua_cmd("logout"),
    })
    table.insert(entries, {
        Text = "Reboot",
        Subtext = "Restart system",
        Icon = "system-reboot",
        Value = lua_cmd("reboot"),
    })
    table.insert(entries, {
        Text = "Shutdown",
        Subtext = "Power off system",
        Icon = "system-shutdown",
        Value = lua_cmd("shutdown"),
    })

    return entries
end
