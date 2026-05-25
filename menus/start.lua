Name = "start"
NamePretty = "Start Menu"
Icon = "start-here-symbolic"
FixedOrder = true
HideFromProviderlist = false
Cache = false

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
    -- Fallback: relative to this script (for development/run from source)
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

-- Load utils on demand via dofile
function GetEntries()
    local entries = {}
    local utils_path = find_utils_path()

    -- Helper to build a lua -e command that loads utils from utils_path
    local function lua_cmd(fn)
        return "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m." .. fn .. "()'"
    end

    -- Apps
    entries[#entries + 1] = {
        Text = "Apps",
        Icon = "applications-other",
        Value = "walker --provider desktopapplications -p Launch...",
    }

    -- Trigger
    entries[#entries + 1] = {
        Text = "Trigger",
        Icon = "preferences-system-notifications",
        SubMenu = "trigger",
    }

    -- Style
    entries[#entries + 1] = {
        Text = "Style",
        Icon = "preferences-desktop-theme",
        SubMenu = "style",
    }

    -- Setup
    entries[#entries + 1] = {
        Text = "Setup",
        Icon = "preferences-system",
        SubMenu = "setup",
    }

    -- Install
    entries[#entries + 1] = {
        Text = "Install",
        Icon = "software-install",
        SubMenu = "install",
    }

    -- Remove
    entries[#entries + 1] = {
        Text = "Remove",
        Icon = "edit-delete",
        SubMenu = "remove",
    }

    -- Update
    entries[#entries + 1] = {
        Text = "Update",
        Icon = "software-update-available",
        SubMenu = "update",
    }

    -- About
    entries[#entries + 1] = {
        Text = "About",
        Icon = "dialog-information",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_about()'",
    }

    -- System
    entries[#entries + 1] = {
        Text = "System",
        Icon = "system-shutdown",
        SubMenu = "system",
    }

    return entries
end
