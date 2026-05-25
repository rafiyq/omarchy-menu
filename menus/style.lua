Name = "style"
NamePretty = "Style"
Icon = "preferences-desktop-theme"
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

    -- Theme
    entries[#entries + 1] = {
        Text = "Theme",
        Icon = "preferences-desktop-theme",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:omarchythemes --width 800 --minheight 400\")'",
    }

    -- Font
    entries[#entries + 1] = {
        Text = "Font",
        Icon = "font-select",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:omarchyfonts --width 350 --minheight 400\")'",
    }

    -- Background
    entries[#entries + 1] = {
        Text = "Background",
        Icon = "preferences-desktop-wallpaper",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_walker(\"-m menus:omarchyBackgroundSelector --width 800 --minheight 400\")'",
    }

    local config_dir = os.getenv("HOME") .. "/.config/hypr"
    if utils_path then
        local ok, utils_mod = pcall(dofile, utils_path)
        if ok and utils_mod and utils_mod.wm_config_dir then
            config_dir = utils_mod.wm_config_dir()
        end
    end

    -- Hyprland Look & Feel
    entries[#entries + 1] = {
        Text = "Hyprland Look & Feel",
        Icon = "hyprland",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.launch_editor(\"" .. config_dir .. "/looknfeel.conf\")'",
    }

    -- Screensaver
    entries[#entries + 1] = {
        Text = "Edit Screensaver",
        Icon = "preferences-desktop-screensaver",
        Value = lua_cmd("launch_screensaver"),
    }

    -- About
    entries[#entries + 1] = {
        Text = "About",
        Icon = "dialog-information",
        Value = lua_cmd("launch_about"),
    }

    return entries
end
