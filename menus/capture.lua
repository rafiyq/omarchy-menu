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

    table.insert(entries, {
        Text = "Screenshot (Region)",
        Subtext = "Select area to capture",
        Icon = "camera-photo",
        Value = lua_cmd("screenshot", "false"),
    })
    table.insert(entries, {
        Text = "Screenshot (Fullscreen)",
        Subtext = "Capture entire screen",
        Icon = "camera-photo",
        Value = lua_cmd("screenshot", "true"),
    })
    table.insert(entries, {
        Text = "Screenrecord",
        Subtext = "Start video recording",
        Icon = "media-record",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.start_screenrecord(false, false, false)'",
    })
    table.insert(entries, {
        Text = "Stop Screenrecord",
        Subtext = "Stop video recording",
        Icon = "media-playback-stop",
        Value = lua_cmd("stop_screenrecord"),
    })
    table.insert(entries, {
        Text = "Text Extraction (OCR)",
        Subtext = "Extract text from image",
        Icon = "edit-select-all",
        Value = lua_cmd("text_extraction"),
    })
    table.insert(entries, {
        Text = "Color Picker",
        Subtext = "Pick color from screen",
        Icon = "color-picker",
        Value = lua_cmd("color_picker"),
    })

    return entries
end
