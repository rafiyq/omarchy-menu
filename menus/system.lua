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

    entries[#entries + 1] = {
        Text = "Screensaver",
        Icon = "preferences-desktop-screensaver",
        Value = lua_cmd("launch_screensaver"),
    }
    entries[#entries + 1] = {
        Text = "Lock",
        Icon = "system-lock-screen",
        Value = lua_cmd("lock_screen"),
    }
    entries[#entries + 1] = {
        Text = "Suspend",
        Icon = "system-suspend",
        Value = lua_cmd("suspend"),
    }
    entries[#entries + 1] = {
        Text = "Hibernate",
        Icon = "system-hibernate",
        Value = lua_cmd("hibernate"),
    }
    entries[#entries + 1] = {
        Text = "Logout",
        Icon = "system-log-out",
        Value = lua_cmd("logout"),
    }
    entries[#entries + 1] = {
        Text = "Reboot",
        Icon = "system-reboot",
        Value = lua_cmd("reboot"),
    }
    entries[#entries + 1] = {
        Text = "Shutdown",
        Icon = "system-shutdown",
        Value = lua_cmd("shutdown"),
    }

    return entries
end
