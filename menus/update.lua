Name = "update"
NamePretty = "Update"
Icon = "software-update-available"
FixedOrder = true
HideFromProviderlist = false
Cache = false

Parent = "top-level"

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

    -- System / Package Update
    entries[#entries + 1] = {
        Text = "System Packages",
        Icon = "system-software-update",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-update\")'",
    }

    -- Individual Channel Updates
    entries[#entries + 1] = {
        Text = "Channel: Stable",
        Icon = "system-software-update",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.channel_set(\"stable\")'",
    }
    entries[#entries + 1] = {
        Text = "Channel: Rc",
        Icon = "system-software-update",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.channel_set(\"rc\")'",
    }
    entries[#entries + 1] = {
        Text = "Channel: Edge",
        Icon = "system-software-update",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.channel_set(\"edge\")'",
    }
    entries[#entries + 1] = {
        Text = "Channel: Dev",
        Icon = "system-software-update",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.channel_set(\"dev\")'",
    }

    -- Extra Themes
    entries[#entries + 1] = {
        Text = "Extra Themes",
        Icon = "preferences-desktop-theme",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-theme-update\")'",
    }

    -- Firmware
    entries[#entries + 1] = {
        Text = "Firmware",
        Icon = "firmware",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-firmware-update\")'",
    }

    return entries
end
