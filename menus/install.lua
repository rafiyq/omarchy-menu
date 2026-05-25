Name = "install"
NamePretty = "Install"
Icon = "software-install"
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

    -- Package
    entries[#entries + 1] = {
        Text = "Package",
        Icon = "package",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.pkg_install()'",
    }

    -- AUR
    entries[#entries + 1] = {
        Text = "AUR Package",
        Icon = "package-aur",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.pkg_aur_install()'",
    }

    -- Web App
    entries[#entries + 1] = {
        Text = "Web App",
        Icon = "applications-internet",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-webapp-install\")'",
    }

    -- TUI
    entries[#entries + 1] = {
        Text = "TUI",
        Icon = "terminal",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-tui-install\")'",
    }

    -- Browser
    entries[#entries + 1] = {
        Text = "Browser",
        Icon = "web-browser",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-browser\")'",
    }

    -- Editor: VSCode
    entries[#entries + 1] = {
        Text = "VSCode",
        Icon = "code",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-vscode\")'",
    }

    -- Editor: Zed
    entries[#entries + 1] = {
        Text = "Zed",
        Icon = "zed",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-zed\")'",
    }

    -- Terminal
    entries[#entries + 1] = {
        Text = "Terminal",
        Icon = "terminal",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-terminal\")'",
    }

    -- AI: Dictation
    entries[#entries + 1] = {
        Text = "Dictation",
        Icon = "microphone-sensitivity-high",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-voxtype-install\")'",
    }

    -- Gaming: Steam
    entries[#entries + 1] = {
        Text = "Steam",
        Icon = "steam",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-gaming-steam\")'",
    }

    -- Gaming: Lutris
    entries[#entries + 1] = {
        Text = "Lutris",
        Icon = "lutris",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-gaming-lutris\")'",
    }

    -- Development environments
    local dev_envs = {
        { name = "Ruby on Rails", icon = "ruby", flag = "ruby" },
        { name = "JavaScript",    icon = "nodejs", flag = "node" },
        { name = "Go",            icon = "go", flag = "go" },
        { name = "PHP",           icon = "php", flag = "php" },
        { name = "Python",        icon = "python", flag = "python" },
        { name = "Elixir",        icon = "elixir", flag = "elixir" },
        { name = "Zig",           icon = "zig", flag = "zig" },
        { name = "Rust",          icon = "rust", flag = "rust" },
        { name = "Java",          icon = "java", flag = "java" },
        { name = ".NET",          icon = "dotnet", flag = "dotnet" },
        { name = "OCaml",         icon = "ocaml", flag = "ocaml" },
        { name = "Clojure",       icon = "clojure", flag = "clojure" },
        { name = "Scala",         icon = "scala", flag = "scala" },
    }

    for _, env in ipairs(dev_envs) do
        entries[#entries + 1] = {
            Text = env.name,
            Icon = env.icon,
            Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-dev-env " .. env.flag .. "\")'",
        }
    end

    -- Style: Theme
    entries[#entries + 1] = {
        Text = "Theme",
        Icon = "preferences-desktop-theme",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.theme_install()'",
    }

    -- Style: Background
    entries[#entries + 1] = {
        Text = "Background",
        Icon = "preferences-desktop-wallpaper",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.theme_bg_install()'",
    }

    return entries
end
