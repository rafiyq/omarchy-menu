Name = "remove"
NamePretty = "Remove"
Icon = "edit-delete"
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

    -- Package
    table.insert(entries, {
        Text = "Package",
        Subtext = "Remove a package",
        Icon = "package",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.pkg_remove()'",
    })

    -- Web App
    table.insert(entries, {
        Text = "Web App",
        Subtext = "Remove web application",
        Icon = "applications-internet",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-webapp-remove\")'",
    })

    -- TUI
    table.insert(entries, {
        Text = "TUI",
        Subtext = "Remove terminal apps",
        Icon = "terminal",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-tui-remove\")'",
    })

    -- Browser
    table.insert(entries, {
        Text = "Browser",
        Subtext = "Remove web browser",
        Icon = "web-browser",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-remove-browser\")'",
    })

    -- Dictation
    table.insert(entries, {
        Text = "Dictation",
        Subtext = "Remove voice typing",
        Icon = "microphone-sensitivity-high",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-voxtype-remove\")'",
    })

    -- Gaming: Steam
    table.insert(entries, {
        Text = "Steam",
        Subtext = "Remove Steam gaming",
        Icon = "steam",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-remove-gaming-steam\")'",
    })

    -- Gaming: Lutris
    table.insert(entries, {
        Text = "Lutris",
        Subtext = "Remove Lutris games",
        Icon = "lutris",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-remove-gaming-lutris\")'",
    })

    return entries
end
