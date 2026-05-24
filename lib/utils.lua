-- wmenu Shared Library for Elephant Providers
-- Self-contained: no external omarchy-* dependencies

local M = {}

-- =============================================================================
-- CONFIGURABLE PATHS (parameterized, defaults to omarchy paths)
-- =============================================================================

function M.config_dir()
    local xdg = os.getenv("XDG_CONFIG_HOME")
    if xdg then
        return xdg .. "/omarchy"
    end
    return os.getenv("HOME") .. "/.config/omarchy"
end

function M.data_dir()
    local xdg = os.getenv("XDG_DATA_HOME")
    if xdg then
        return xdg .. "/omarchy"
    end
    return os.getenv("HOME") .. "/.local/share/omarchy"
end

function M.state_dir()
    local xdg = os.getenv("XDG_STATE_HOME")
    if xdg then
        return xdg .. "/omarchy"
    end
    return os.getenv("HOME") .. "/.local/state/omarchy"
end

M.OMARCHY_CONFIG = M.config_dir()
M.STATE_DIR = M.state_dir()

-- =============================================================================
-- FILE / PATH UTILITIES
-- =============================================================================

function M.file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

function M.read_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

function M.write_file(path, content)
    local f, err = io.open(path, "w")
    if not f then
        return false, err
    end
    f:write(content)
    f:close()
    return true
end

function M.ensure_dir(path)
    local handle = io.popen("mkdir -p '" .. path:gsub("'", "'\\''") .. "' 2>/dev/null")
    if handle then
        handle:close()
    end
    return M.file_exists(path)
end

-- =============================================================================
-- COMMAND EXECUTION
-- =============================================================================

function M.cmd_exists(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not handle then
        return false
    end
    local result = handle:read("*a")
    handle:close()
    return result ~= "" and result ~= nil
end

function M.exec(cmd)
    local handle = io.popen(cmd .. " 2>&1; echo $?")
    if not handle then
        return nil, -1
    end
    local output = handle:read("*a")
    handle:close()
    local exit_code = tonumber(output:match("(%d+)\n$")) or -1
    local trimmed = output:gsub("%d+\n$", "")
    return trimmed, exit_code
end

function M.exec_silent(cmd)
    os.execute(cmd .. " >/dev/null 2>&1")
end

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================

function M.notify(title, text, urgency)
    urgency = urgency or "normal"
    if M.cmd_exists("notify-send") then
        os.execute("notify-send -u " .. urgency .. " '" .. title .. "' '" .. text .. "' >/dev/null 2>&1")
    end
end

function M.notify_icon(title, text, icon, urgency)
    urgency = urgency or "normal"
    if M.cmd_exists("notify-send") then
        local icon_arg = icon and " -i '" .. icon .. "'" or "" 
        os.execute("notify-send" .. icon_arg .. " -u " .. urgency .. " '" .. title .. "' '" .. text .. "' >/dev/null 2>&1")
    end
end

-- =============================================================================
-- STATE MANAGEMENT
-- =============================================================================

function M.init_state()
    M.ensure_dir(M.STATE_DIR .. "/toggles")
    return M.file_exists(M.STATE_DIR)
end

function M.is_enabled(toggle_name)
    local path = M.STATE_DIR .. "/toggles/" .. toggle_name
    return M.file_exists(path)
end

function M.enable(toggle_name, notify_text)
    M.init_state()
    local path = M.STATE_DIR .. "/toggles/" .. toggle_name
    local success, err = M.write_file(path, "")
    if success and notify_text then
        M.notify("Enabled", notify_text)
    end
    return success
end

function M.disable(toggle_name, notify_text)
    local path = M.STATE_DIR .. "/toggles/" .. toggle_name
    if M.file_exists(path) then
        os.execute("rm -f '" .. path:gsub("'", "'\\''") .. "'")
    end
    if notify_text then
        M.notify("Disabled", notify_text)
    end
    return true
end

function M.toggle_state(toggle_name, enabled_text, disabled_text)
    if M.is_enabled(toggle_name) then
        M.disable(toggle_name, disabled_text)
        return false
    else
        M.enable(toggle_name, enabled_text)
        return true
    end
end

-- =============================================================================
-- HYPRLAND / WM INTEGRATION
-- =============================================================================

function M.hyprctl(cmd)
    if M.cmd_exists("hyprctl") then
        local handle = io.popen("hyprctl " .. cmd .. " 2>/dev/null")
        if handle then
            local result = handle:read("*a")
            handle:close()
            return result
        end
    end
    return nil
end

function M.is_process_running(name)
    local handle = io.popen("pgrep -x '" .. name .. "' >/dev/null 2>&1 && echo 'yes' || echo 'no'")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:find("yes") ~= nil
    end
    return false
end

function M.kill_process(name, signal)
    signal = signal or ""
    if signal ~= "" then
        signal = "-" .. signal .. " "
    end
    os.execute("pkill " .. signal .. "-x '" .. name .. "' >/dev/null 2>&1")
end

-- =============================================================================
-- SYSTEM ACTIONS
-- =============================================================================

function M.lock_screen()
    if M.cmd_exists("hyprlock") and not M.is_process_running("hyprlock") then
        os.execute("(hyprlock; " ..
            "hyprctl keyword cursor:invisible false >/dev/null 2>&1; " ..
            "pkill -x tte >/dev/null 2>&1; " ..
            "pkill -f org.omarchy.screensaver >/dev/null 2>&1) &")
        M.exec_silent("hyprctl switchxkblayout all 0")
        if M.is_process_running("1password") then
            os.execute("1password --lock >/dev/null 2>&1 &")
        end
    else
        M.exec_silent("loginctl lock-session")
    end
end

function M.logout()
    M.exec_silent("nohup bash -c 'sleep 2 && uwsm stop' >/dev/null 2>&1 &")
    M.exec_silent("hyprctl dispatch closewindow regex:.* >/dev/null 2>&1")
    os.execute("sleep 1")
end

function M.suspend()
    M.notify("System", "Suspending...")
    M.exec_silent("systemctl suspend")
end

function M.reboot()
    M.notify("System", "Rebooting...")
    M.exec_silent("nohup bash -c 'sleep 2 && systemctl reboot --no-wall' >/dev/null 2>&1 &")
    M.exec_silent("hyprctl dispatch closewindow regex:.* >/dev/null 2>&1")
    os.execute("sleep 1")
end

function M.shutdown()
    M.notify("System", "Shutting down...")
    M.exec_silent("nohup bash -c 'sleep 2 && systemctl poweroff --no-wall' >/dev/null 2>&1 &")
    M.exec_silent("hyprctl dispatch closewindow regex:.* >/dev/null 2>&1")
    os.execute("sleep 1")
end

-- =============================================================================
-- HIBERNATION DETECTION
-- =============================================================================

function M.hibernation_supported()
    local f = io.open("/sys/power/image_size", "r")
    if not f then
        return false
    end
    local image_size_str = f:read("*a")
    f:close()
    if not image_size_str then
        return false
    end
    local trimmed = image_size_str:gsub("^%s*(.-)%s*$", "%1")
    local image_size = tonumber(trimmed)
    if not image_size or image_size == 0 then
        return false
    end
    local swaptotal_kb = 0
    local swap_handle = io.open("/proc/swaps", "r")
    if swap_handle then
        local first = true
        for line in swap_handle:lines() do
            if first then
                first = false
            else
                if not line:find("zram") then
                    local size_str = line:match("%S+%s+%S+%s+(%d+)")
                    if size_str then
                        swaptotal_kb = swaptotal_kb + tonumber(size_str)
                    end
                end
            end
        end
        swap_handle:close()
    end
    return swaptotal_kb > 0
end

function M.hibernate()
    if M.hibernation_supported() then
        M.notify("System", "Hibernating...")
        M.exec_silent("systemctl hibernate")
    else
        M.notify("Error", "Hibernation not supported", "critical")
    end
end

-- =============================================================================
-- SCREENSAVER
-- =============================================================================

function M.launch_screensaver()
    M.exec_silent("pkill -x tte >/dev/null 2>&1")
end

function M.screensaver_enabled()
    return not M.is_enabled("screensaver-off")
end

function M.toggle_screensaver()
    M.toggle_state("screensaver-off", "Screensaver disabled", "Screensaver enabled")
end

-- =============================================================================
-- NIGHTLIGHT
-- =============================================================================

function M.toggle_nightlight()
    if M.cmd_exists("hyprsunset") then
        if M.is_process_running("hyprsunset") then
            local current = M.exec("hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+'")
            if current and tonumber(current) == 4000 then
                M.exec_silent("hyprctl hyprsunset temperature 6000 >/dev/null 2>&1")
                M.notify("Nightlight", "Nightlight disabled")
            else
                M.exec_silent("hyprctl hyprsunset temperature 4000 >/dev/null 2>&1")
                M.notify("Nightlight", "Nightlight enabled (4000K)")
            end
        else
            os.execute("setsid uwsm-app -- hyprsunset >/dev/null 2>&1 &")
            os.execute("sleep 1")
            M.exec_silent("hyprctl hyprsunset temperature 4000 >/dev/null 2>&1")
            M.notify("Nightlight", "Nightlight enabled (4000K)")
        end
    end
end

-- =============================================================================
-- IDLE LOCK
-- =============================================================================

function M.toggle_idle_lock()
    if M.is_process_running("hypridle") then
        M.kill_process("hypridle")
        M.notify("Idle Lock", "Idle lock disabled")
    else
        os.execute("uwsm-app -- hypridle >/dev/null 2>&1 &")
        M.notify("Idle Lock", "Idle lock enabled")
    end
end

-- =============================================================================
-- NOTIFICATIONS TOGGLE
-- =============================================================================

function M.toggle_notifications()
    if M.cmd_exists("makoctl") then
        M.exec_silent("makoctl mode -t do-not-disturb >/dev/null 2>&1")
        local modes = M.exec("makoctl mode 2>/dev/null")
        if modes and modes:find("do%%-not%%-disturb") then
            M.notify("Notifications", "Do Not Disturb enabled")
        else
            M.notify("Notifications", "Notifications enabled")
        end
    end
end

-- =============================================================================
-- TOP BAR / WAYBAR
-- =============================================================================

function M.toggle_waybar()
    if M.is_process_running("waybar") then
        M.kill_process("waybar", "9")
    else
        os.execute("uwsm-app -- waybar >/dev/null 2>&1 &")
    end
end

function M.restart_waybar()
    M.kill_process("waybar", "9")
    os.execute("uwsm-app -- waybar >/dev/null 2>&1 &")
end

-- =============================================================================
-- HYPRLAND WINDOW / WORKSPACE MANAGEMENT
-- =============================================================================

function M.toggle_workspace_layout()
    M.exec_silent("hyprctl dispatch togglesplit >/dev/null 2>&1")
end

function M.toggle_window_gaps()
    M.exec_silent("hyprctl dispatch setfloating && hyprctl dispatch resizeactive exact 0 0 >/dev/null 2>&1")
end

function M.toggle_window_ratio()
    M.exec_silent("hyprctl reload >/dev/null 2>&1")
end

function M.cycle_monitor_scaling()
    M.exec_silent("hyprctl dispatch cyclemonitorscale +0.1 >/dev/null 2>&1")
end

-- =============================================================================
-- REMINDERS
-- =============================================================================

function M.set_reminder(minutes, message)
    minutes = minutes or 60
    message = message or "Reminder"
    if M.cmd_exists("systemd-run") then
        local cmd = "systemd-run --user --on-active=" .. minutes .. "m --collect --timer-property=Description='Reminder' bash -c \"notify-send -u critical 'Reminder' '" .. message .. "'\" >/dev/null 2>&1"
        M.exec_silent(cmd)
        M.notify("Reminder", "Set for " .. minutes .. " minutes")
    end
end

function M.show_reminders()
    if M.cmd_exists("systemctl") then
        M.exec_silent("systemctl --user list-timers --all >/dev/null 2>&1")
    end
end

function M.clear_reminders()
    if M.cmd_exists("systemctl") then
        M.exec_silent("systemctl --user list-timers --all --no-pager 2>/dev/null | grep -E '\\.timer' | awk '{print $1}' | xargs -r systemctl --user stop >/dev/null 2>&1")
    end
end

-- =============================================================================
-- SHARE
-- =============================================================================

function M.share_clipboard()
    if M.cmd_exists("localsend") then
        M.exec_silent("systemd-run --user --quiet --collect localsend --headless send --clipboard >/dev/null 2>&1 &")
    end
end

function M.share_file(path)
    if M.cmd_exists("localsend") then
        M.exec_silent("systemd-run --user --quiet --collect localsend --headless send '" .. path .. "' >/dev/null 2>&1 &")
    end
end

function M.share_folder(path)
    if M.cmd_exists("localsend") then
        M.exec_silent("systemd-run --user --quiet --collect localsend --headless send '" .. path .. "' >/dev/null 2>&1 &")
    end
end

-- =============================================================================
-- CAPTURE
-- =============================================================================

function M.screenshot(fullscreen)
    local timestamp = os.date("%Y%m%d-%H%M%S")
    local dir = os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures")
    local filename = dir .. "/screenshot-" .. timestamp .. ".png"
    if fullscreen then
        M.exec_silent("grim '" .. filename .. "' >/dev/null 2>&1")
    else
        M.exec_silent("grim -g \"$(slurp)\" '" .. filename .. "' >/dev/null 2>&1")
    end
    if M.cmd_exists("wl-copy") then
        M.exec_silent("wl-copy < '" .. filename .. "' >/dev/null 2>&1")
    end
    M.notify("Screenshot", "Saved to " .. filename)
    return filename
end

function M.start_screenrecord(with_audio, with_mic, with_webcam)
    local script = "wmenu-capture-screenrecording"
    if with_webcam then
        script = script .. " --with-webcam"
    end
    if with_mic then
        script = script .. " --with-microphone-audio"
    end
    if with_audio then
        script = script .. " --with-desktop-audio"
    end
    M.exec_silent(script .. " >/dev/null 2>&1 &")
end

function M.stop_screenrecord()
    M.exec_silent("wmenu-capture-screenrecording --stop-recording >/dev/null 2>&1")
end

function M.text_extraction()
    local tmpfile = "/tmp/wmenu-ocr.png"
    M.exec_silent("grim -g \"$(slurp)\" '" .. tmpfile .. "' >/dev/null 2>&1")
    if M.cmd_exists("tesseract") then
        local text = M.exec("tesseract '" .. tmpfile .. "' - -l eng 2>/dev/null")
        if text and text ~= "" then
            if M.cmd_exists("wl-copy") then
                M.write_file("/tmp/wmenu-ocr-text.txt", text)
                M.exec_silent("wl-copy < /tmp/wmenu-ocr-text.txt >/dev/null 2>&1")
            end
            M.notify("OCR", "Text copied to clipboard")
            return text
        end
    end
    return nil
end

function M.color_picker()
    if M.cmd_exists("hyprpicker") then
        M.exec_silent("hyprpicker -a >/dev/null 2>&1 &")
    end
end

-- =============================================================================
-- TERMINAL / EDITOR / LAUNCHERS
-- =============================================================================

function M.launch_about()
    if M.cmd_exists("fastfetch") then
        os.execute("fastfetch &")
    else
        os.execute("uname -a")
    end
end

function M.launch_editor(path)
    local editor = os.getenv("EDITOR") or "nvim"
    if M.cmd_exists(editor) then
        os.execute("setsid " .. editor .. " '" .. path .. "' >/dev/null 2>&1 &")
    else
        os.execute("setsid vi '" .. path .. "' >/dev/null 2>&1 &")
    end
end

function M.terminal_run(cmd)
    for _, term in ipairs({"foot", "kitty", "alacritty", "ghostty", "wezterm"}) do
        if M.cmd_exists(term) then
            os.execute(term .. " " .. cmd .. " &")
            return
        end
    end
    os.execute("xdg-terminal-exec " .. cmd .. " &")
end

function M.launch_walker(args)
    if M.cmd_exists("walker") then
        os.execute("setsid walker " .. (args or "") .. " >/dev/null 2>&1 &")
    end
end

-- =============================================================================
-- PACKAGE MANAGEMENT (thin wrappers calling omarchy-* or fallback)
-- =============================================================================

function M.pkg_install(pkg)
    if M.cmd_exists("omarchy-pkg-install") then
        M.terminal_run("omarchy-pkg-install '" .. pkg .. "'")
    else
        M.terminal_run("'sudo pacman -S --needed --noconfirm '" .. pkg .. "' 2>/dev/null || sudo apt-get install -y '" .. pkg .. "' 2>/dev/null || sudo dnf install -y '" .. pkg .. "''")
    end
end

function M.pkg_aur_install(pkg)
    if M.cmd_exists("omarchy-pkg-aur-install") then
        M.terminal_run("omarchy-pkg-aur-install '" .. pkg .. "'")
    else
        M.terminal_run("yay -S '" .. pkg .. "'")
    end
end

function M.pkg_remove(pkg)
    if M.cmd_exists("omarchy-pkg-remove") then
        M.terminal_run("omarchy-pkg-remove '" .. pkg .. "'")
    else
        M.terminal_run("'sudo pacman -Rns --noconfirm '" .. pkg .. "' 2>/dev/null || sudo apt-get remove -y '" .. pkg .. "' 2>/dev/null || sudo dnf remove -y '" .. pkg .. "''")
    end
end

function M.update_system()
    if M.cmd_exists("omarchy-update") then
        M.terminal_run("omarchy-update")
    else
        M.terminal_run("'sudo pacman -Syu --noconfirm 2>/dev/null || sudo apt-get update && sudo apt-get upgrade -y 2>/dev/null || sudo dnf upgrade -y 2>/dev/null'")
    end
end

-- =============================================================================
-- WM / THEME / CONFIG
-- =============================================================================

function M.wm_config_dir()
    return M.OMARCHY_CONFIG
end

function M.restart_service(name)
    M.exec_silent("systemctl --user restart " .. name .. ".service >/dev/null 2>&1")
end

function M.wm_restart()
    M.exec_silent("hyprctl reload >/dev/null 2>&1")
end

function M.restart_walker()
    M.kill_process("walker", "9")
    os.execute("setsid walker >/dev/null 2>&1 &")
end

function M.restart_waybar_lua()
    M.restart_waybar()
end

function M.restart_hypridle()
    M.kill_process("hypridle")
    os.execute("uwsm-app -- hypridle >/dev/null 2>&1 &")
end

function M.restart_hyprlock()
    -- no-op, hyprlock is on-demand
end

function M.restart_hyprsunset()
    M.kill_process("hyprsunset")
    os.execute("uwsm-app -- hyprsunset >/dev/null 2>&1 &")
end

function M.restart_swayosd()
    M.exec_silent("systemctl --user restart swayosd.service >/dev/null 2>&1")
end

function M.theme_install()
    if M.cmd_exists("omarchy-theme-install") then
        M.terminal_run("omarchy-theme-install")
    else
        M.notify("Theme", "Theme installer not available", "critical")
    end
end

function M.theme_bg_install()
    if M.cmd_exists("omarchy-theme-bg-install") then
        M.terminal_run("omarchy-theme-bg-install")
    else
        M.notify("Theme", "Background installer not available", "critical")
    end
end

function M.channel_set(channel)
    if M.cmd_exists("omarchy-channel-set") then
        M.terminal_run("omarchy-channel-set " .. channel)
    else
        M.notify("Channel", "Channel switcher not available", "critical")
    end
end

function M.setup_dns()
    if M.cmd_exists("omarchy-setup-dns") then
        M.terminal_run("omarchy-setup-dns")
    else
        M.notify("DNS", "DNS setup not available", "critical")
    end
end

function M.menu_keybindings()
    if M.cmd_exists("omarchy-menu-keybindings") then
        os.execute("omarchy-menu-keybindings &")
    else
        M.notify("Keybindings", "Keybindings menu not available", "critical")
    end
end
end

-- =============================================================================
-- PLATFORM / DISTRIBUTION / WM DETECTION
-- =============================================================================

function M.detect_distro()
    local f = io.open("/etc/os-release", "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    local id = content:match('^ID="?([^"\n]+)"?'):lower()
    local id_like = content:match('ID_LIKE="?([^"\n]+)"?'):lower()
    if id:find("arch") or id:find("artix") or id:find("manjaro") or
       id:find("endeavouros") or id:find("cachyos") or id:find("garuda") then
        return "arch"
    end
    if id:find("debian") or id:find("ubuntu") or id:find("linuxmint") or
       id:find("pop") or id:find("elementary") or id:find("zorin") or
       id:find("kali") or id:find("raspbian") then
        return "debian"
    end
    if id:find("fedora") or id:find("rhel") or id:find("centos") or
       id:find("rockylinux") or id:find("almalinux") or id:find("nobara") then
        return "fedora"
    end
    if id_like then
        if id_like:find("arch") then return "arch" end
        if id_like:find("debian") then return "debian" end
        if id_like:find("fedora") or id_like:find("rhel") then return "fedora" end
    end
    return nil
end

function M.detect_wm()
    if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then
        return "hyprland"
    end
    if os.getenv("SWAYSOCK") then
        return "sway"
    end
    local desktop = os.getenv("XDG_CURRENT_DESKTOP") or ""
    desktop = desktop:lower()
    if desktop:find("hyprland") then return "hyprland" end
    if desktop:find("sway") then return "sway" end
    return nil
end

function M.hw_hybrid_gpu()
    local handle = io.popen("lspci -nn 2>/dev/null | grep -c '\\[030[02]\\]'")
    if handle then
        local result = handle:read("*a")
        handle:close()
        local count = tonumber(result) or 0
        return count >= 2
    end
    return false
end

function M.hw_touchpad()
    local handle = io.popen("grep -qE 'touchpad|trackpad' /proc/bus/input/devices 2>/dev/null && echo 'yes' || echo 'no'")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:find("yes") ~= nil
    end
    return false
end

function M.hw_touchscreen()
    local handle = io.popen("grep -qiE 'touchscreen' /proc/bus/input/devices 2>/dev/null && echo 'yes' || echo 'no'")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:find("yes") ~= nil
    end
    return false
end

-- =============================================================================
-- PACKAGE MANAGEMENT (port from pkg.sh to pure Lua)
-- =============================================================================

function M.pkg_manager()
    local distro = M.detect_distro()
    if distro == "arch" then return "pacman" end
    if distro == "debian" then return "apt" end
    if distro == "fedora" then return "dnf" end
    return nil
end

function M.pkg_install(packages)
    local manager = M.pkg_manager()
    if not manager then
        M.notify("Error", "Unknown package manager", "critical")
        return false
    end
    if manager == "pacman" then
        return M.exec_silent("sudo pacman -S --needed --noconfirm " .. packages) == 0
    elseif manager == "apt" then
        return M.exec_silent("sudo apt-get install -y " .. packages) == 0
    elseif manager == "dnf" then
        return M.exec_silent("sudo dnf install -y " .. packages) == 0
    end
end

function M.pkg_remove(packages)
    local manager = M.pkg_manager()
    if not manager then
        M.notify("Error", "Unknown package manager", "critical")
        return false
    end
    if manager == "pacman" then
        return M.exec_silent("sudo pacman -Rns --noconfirm " .. packages) == 0
    elseif manager == "apt" then
        return M.exec_silent("sudo apt-get remove -y " .. packages) == 0
    elseif manager == "dnf" then
        return M.exec_silent("sudo dnf remove -y " .. packages) == 0
    end
end

function M.pkg_update()
    local manager = M.pkg_manager()
    if not manager then
        M.notify("Error", "Unknown package manager", "critical")
        return false
    end
    if manager == "pacman" then
        return M.exec_silent("sudo pacman -Syu --noconfirm") == 0
    elseif manager == "apt" then
        return M.exec_silent("sudo apt-get update && sudo apt-get upgrade -y") == 0
    elseif manager == "dnf" then
        return M.exec_silent("sudo dnf upgrade -y") == 0
    end
end

function M.pkg_installed(pkg)
    local manager = M.pkg_manager()
    if not manager then return false end
    if manager == "pacman" then
        return M.exec("pacman -Qi " .. pkg .. " 2>/dev/null")
    elseif manager == "apt" then
        return M.exec("dpkg -s " .. pkg .. " 2>/dev/null")
    elseif manager == "dnf" then
        return M.exec("rpm -q " .. pkg .. " 2>/dev/null")
    end
end

-- =============================================================================
-- TERMINAL / EDITOR / LAUNCHERS (port from core.sh)
-- =============================================================================

function M.terminal_detect()
    for _, term in ipairs({"foot", "kitty", "alacritty", "ghostty", "wezterm"}) do
        if M.cmd_exists(term) then
            return term
        end
    end
    if M.cmd_exists("xdg-terminal-exec") then
        return "xdg-terminal-exec"
    end
    return nil
end

function M.terminal_run(cmd)
    local term = M.terminal_detect()
    if term == "xdg-terminal-exec" then
        os.execute("xdg-terminal-exec " .. cmd .. " &")
    elseif term then
        os.execute(term .. " " .. cmd .. " &")
    else
        M.notify("Error", "No terminal emulator found", "critical")
    end
end

function M.present_terminal(cmd)
    local term = M.terminal_detect()
    if term then
        os.execute(term .. " -- /bin/bash -c '" .. cmd .. "; echo; read -rp \"Press Enter to close...\"'")
    else
        M.notify("Error", "No terminal emulator found", "critical")
    end
end

function M.open_in_editor(path)
    local editor = os.getenv("EDITOR") or "nvim"
    if M.cmd_exists(editor) then
        os.execute("setsid " .. editor .. " '" .. path .. "' >/dev/null 2>&1 &")
    else
        os.execute("setsid vi '" .. path .. "' >/dev/null 2>&1 &")
    end
end

-- =============================================================================
-- WM FUNCTIONS (ported from wm.sh)
-- =============================================================================

function M.wm_config_dir()
    local wm = M.detect_wm()
    if wm == "hyprland" then
        return os.getenv("HOME") .. "/.config/hypr"
    elseif wm == "sway" then
        return os.getenv("HOME") .. "/.config/sway"
    else
        return os.getenv("HOME") .. "/.config"
    end
end

function M.wm_lock()
    local wm = M.detect_wm()
    if wm == "hyprland" and M.cmd_exists("hyprlock") then
        os.execute("hyprlock &")
    elseif wm == "sway" and M.cmd_exists("swaylock") then
        os.execute("swaylock &")
    else
        M.exec_silent("loginctl lock-session")
    end
end

function M.wm_logout()
    local wm = M.detect_wm()
    if wm == "hyprland" then
        M.exec_silent("hyprctl dispatch exit")
    elseif wm == "sway" then
        M.exec_silent("swaymsg exit")
    else
        M.exec_silent("loginctl terminate-session")
    end
end

function M.wm_gaps_toggle()
    local wm = M.detect_wm()
    if wm == "hyprland" then
        local current = M.exec("hyprctl getoption general:gaps_in -j 2>/dev/null | jq -r '.int // 5' 2>/dev/null || echo '5'")
        current = tonumber(current) or 5
        if current > 0 then
            M.exec_silent("hyprctl keyword general:gaps_in 0")
            M.exec_silent("hyprctl keyword general:gaps_out 0")
            M.notify("Gaps", "No gaps")
        else
            M.exec_silent("hyprctl keyword general:gaps_in 5")
            M.exec_silent("hyprctl keyword general:gaps_out 8")
            M.notify("Gaps", "Default gaps")
        end
    elseif wm == "sway" then
        M.exec_silent("swaymsg gaps inner current 0")
        M.notify("Gaps", "Toggled")
    else
        M.notify("Gaps", "Not supported on this WM", "critical")
    end
end

function M.wm_floating_toggle()
    local wm = M.detect_wm()
    if wm == "hyprland" then
        M.exec_silent("hyprctl dispatch togglefloating")
        M.notify("Window", "Toggled floating")
    elseif wm == "sway" then
        M.exec_silent("swaymsg floating toggle")
        M.notify("Window", "Toggled floating")
    else
        M.notify("Floating", "Not supported on this WM", "critical")
    end
end

function M.wm_bar_toggle()
    if M.is_process_running("waybar") then
        M.kill_process("waybar")
        M.notify("Bar", "Hidden")
    else
        os.execute("waybar &")
        M.notify("Bar", "Shown")
    end
end

function M.wm_restart()
    local wm = M.detect_wm()
    if wm == "hyprland" then
        M.exec_silent("hyprctl reload")
    elseif wm == "sway" then
        M.exec_silent("swaymsg reload")
    else
        M.notify("Restart", "Not supported on this WM", "critical")
    end
end

-- =============================================================================
-- CAPTURE FUNCTIONS (ported from capture.sh)
-- =============================================================================

function M.capture_screenshot()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local dir = os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures")
    M.ensure_dir(dir)
    local target = dir .. "/screenshot_" .. timestamp .. ".png"

    if M.cmd_exists("grim") then
        if M.cmd_exists("slurp") then
            M.exec_silent("grim -g \"$(slurp)\" '" .. target .. "'")
        else
            M.exec_silent("grim '" .. target .. "'")
        end
        if M.cmd_exists("wl-copy") then
            M.exec_silent("wl-copy < '" .. target .. "'")
        end
        M.notify("Screenshot", "Saved and copied to clipboard")
    else
        M.notify("Screenshot", "grim is not installed", "critical")
    end
end

function M.capture_text_extraction()
    if not M.cmd_exists("grim") or not M.cmd_exists("tesseract") then
        M.notify("Text Extraction", "grim and tesseract are required", "critical")
        return
    end
    local text = M.exec("grim -g $(slurp) - | tesseract -l eng - - 2>/dev/null")
    if text and text ~= "" then
        M.write_file("/tmp/wmenu-ocr.txt", text)
        M.exec_silent("wl-copy < /tmp/wmenu-ocr.txt")
        M.notify("Text Extraction", "Copied to clipboard")
    else
        M.notify("Text Extraction", "No text detected", "critical")
    end
end

function M.capture_screenrecording(...)
    if not M.cmd_exists("wf-recorder") then
        M.notify("Screen Recording", "wf-recorder is not installed", "critical")
        return
    end
    local dir = os.getenv("XDG_VIDEOS_DIR") or (os.getenv("HOME") .. "/Videos")
    M.ensure_dir(dir)
    local output = dir .. "/recording_" .. os.date("%Y%m%d_%H%M%S") .. ".mp4"
    local audio_args = {}
    for _, arg in ipairs({...}) do
        if arg == "--with-desktop-audio" then
            table.insert(audio_args, "-a")
        elseif arg == "--with-microphone-audio" then
            table.insert(audio_args, "-a $(pactl get-default-source)")
        end
    end
    os.execute("wf-recorder " .. table.concat(audio_args, " ") .. " -f '" .. output .. "' &")
    M.notify("Screen Recording", "Recording started: " .. output)
end

function M.capture_colorpick()
    if M.cmd_exists("hyprpicker") then
        os.execute("hyprpicker -a")
    else
        M.notify("Color Picker", "hyprpicker is not installed", "critical")
    end
end

function M.get_webcam_list()
    if not M.cmd_exists("v4l2-ctl") then
        return {}
    end
    local handle = io.popen("v4l2-ctl --list-devices 2>/dev/null")
    if not handle then
        return {}
    end
    local lines = {}
    for line in handle:lines() do
        table.insert(lines, line)
    end
    handle:close()
    return lines
end

-- =============================================================================
-- SERVICE RESTARTS (ported from services.sh)
-- =============================================================================

function M.restart_hypridle()
    M.exec_silent("systemctl --user restart hypridle 2>/dev/null || killall -HUP hypridle 2>/dev/null")
end

function M.restart_hyprsunset()
    M.exec_silent("systemctl --user restart hyprsunset 2>/dev/null || killall -HUP hyprsunset 2>/dev/null")
end

function M.restart_mako()
    M.exec_silent("systemctl --user restart mako 2>/dev/null || { killall mako 2>/dev/null; mako & }")
end

function M.restart_swayosd()
    M.exec_silent("systemctl --user restart swayosd 2>/dev/null || { killall swayosd 2>/dev/null; swayosd & }")
end

function M.restart_pipewire()
    M.exec_silent("systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null")
end

function M.restart_wifi()
    M.exec_silent("sudo systemctl restart NetworkManager 2>/dev/null")
end

function M.restart_bluetooth()
    M.exec_silent("sudo systemctl restart bluetooth 2>/dev/null")
end

-- =============================================================================
-- FONT MANAGEMENT (ported from services.sh)
-- =============================================================================

function M.font_list()
    local handle = io.popen("fc-list : family 2>/dev/null | sed 's/,.*//' | sort -u | head -50")
    if not handle then
        return {}
    end
    local fonts = {}
    for line in handle:lines() do
        table.insert(fonts, line)
    end
    handle:close()
    return fonts
end

function M.font_current()
    local conf = M.wm_config_dir() .. "/looknfeel.conf"
    local f = io.open(conf, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content:match("font%.name=(.-)") or nil
end

function M.font_set(name)
    local conf = M.wm_config_dir() .. "/looknfeel.conf"
    local f = io.open(conf, "r")
    if not f then
        M.notify("Font", "No looknfeel.conf found", "critical")
        return false
    end
    local content = f:read("*a")
    f:close()
    content = content:gsub("font%.name=[^
]+", "font.name=" .. name)
    M.write_file(conf, content)
    M.notify("Font", "Set to " .. name)
    return true
end

-- =============================================================================
-- RETURN MODULE
-- =============================================================================

return M
