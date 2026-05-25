Name = "capture"
NamePretty = "Capture"
Icon = "camera-photo-symbolic"
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

    entries[#entries + 1] = {
        Text = "Screenshot (Region)",
        Icon = "camera-photo",
        Value = lua_cmd("screenshot", "false"),
    }
    entries[#entries + 1] = {
        Text = "Screenshot (Fullscreen)",
        Icon = "camera-photo",
        Value = lua_cmd("screenshot", "true"),
    }
    entries[#entries + 1] = {
        Text = "Screenrecord",
        Icon = "media-record",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.start_screenrecord(false, false, false)'",
    }
    entries[#entries + 1] = {
        Text = "Stop Screenrecord",
        Icon = "media-playback-stop",
        Value = lua_cmd("stop_screenrecord"),
    }
    entries[#entries + 1] = {
        Text = "Text Extraction (OCR)",
        Icon = "edit-select-all",
        Value = lua_cmd("text_extraction"),
    }
    entries[#entries + 1] = {
        Text = "Color Picker",
        Icon = "color-picker",
        Value = lua_cmd("color_picker"),
    }

    return entries
end
