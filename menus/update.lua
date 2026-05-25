Name = "update"
NamePretty = "Update"
Icon = "software-update-available"
FixedOrder = true
HideFromProviderlist = false
Cache = false

Parent = "start"

Action = "%VALUE%"

-- Self-contained path
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
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.update_system()'",
    }

    -- Individual Channel Updates
    for _, channel in ipairs({"Stable", "Rc", "Edge", "Dev"}) do
        entries[#entries + 1] = {
            Text = "Channel: " .. channel,
            Icon = "system-software-update",
            Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.channel_set(\"" .. channel:lower() .. "\")'",
        }
    end

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
