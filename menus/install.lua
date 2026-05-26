Name = "install"
NamePretty = "Install"
Icon = "software-install"
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

    -- Package
    table.insert(entries, {
        Text = "Package",
        Subtext = "Install a package",
        Icon = "package",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.pkg_install()'",
    })

    -- AUR
    table.insert(entries, {
        Text = "AUR Package",
        Subtext = "Install from AUR",
        Icon = "package-aur",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.pkg_aur_install()'",
    })

    -- Web App
    table.insert(entries, {
        Text = "Web App",
        Subtext = "Install web application",
        Icon = "applications-internet",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-webapp-install\")'",
    })

    -- TUI
    table.insert(entries, {
        Text = "TUI",
        Subtext = "Install terminal apps",
        Icon = "terminal",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-tui-install\")'",
    })

    -- Browser
    table.insert(entries, {
        Text = "Browser",
        Subtext = "Install web browser",
        Icon = "web-browser",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-browser\")'",
    })

    -- Editor: VSCode
    table.insert(entries, {
        Text = "VSCode",
        Subtext = "Install VS Code",
        Icon = "code",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-vscode\")'",
    })

    -- Editor: Zed
    table.insert(entries, {
        Text = "Zed",
        Subtext = "Install Zed editor",
        Icon = "zed",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-zed\")'",
    })

    -- Terminal
    table.insert(entries, {
        Text = "Terminal",
        Subtext = "Install terminal emulator",
        Icon = "terminal",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-terminal\")'",
    })

    -- AI: Dictation
    table.insert(entries, {
        Text = "Dictation",
        Subtext = "Install voice typing",
        Icon = "microphone-sensitivity-high",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-voxtype-install\")'",
    })

    -- Gaming: Steam
    table.insert(entries, {
        Text = "Steam",
        Subtext = "Install Steam gaming",
        Icon = "steam",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-gaming-steam\")'",
    })

    -- Gaming: Lutris
    table.insert(entries, {
        Text = "Lutris",
        Subtext = "Install Lutris games",
        Icon = "lutris",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-gaming-lutris\")'",
    })

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
        table.insert(entries, {
            Text = env.name,
            Icon = env.icon,
            Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.terminal_run(\"omarchy-install-dev-env " .. env.flag .. "\")'",
        })
    end

    -- Style: Theme
    table.insert(entries, {
        Text = "Theme",
        Subtext = "Install color theme",
        Icon = "preferences-desktop-theme",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.theme_install()'",
    })

    -- Style: Background
    table.insert(entries, {
        Text = "Background",
        Subtext = "Install background image",
        Icon = "preferences-desktop-wallpaper",
        Value = "lua -e 'local m = dofile(\"" .. (utils_path or "") .. "\"); m.theme_bg_install()'",
    })

    return entries
end
