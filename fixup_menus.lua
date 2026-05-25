-- Helper script to replace hardcoded omarchy-* commands in menus/*.lua with utils.lua function calls
-- Usage: lua fixup_menus.lua

local replacements = {
    -- install.lua
    ['m.terminal_run("omarchy-pkg-install")'] = 'm.pkg_install()',
    ['m.terminal_run("omarchy-pkg-aur-install")'] = 'm.pkg_aur_install()',
    ['m.terminal_run("omarchy-theme-install")'] = 'm.theme_install()',
    ['m.terminal_run("omarchy-theme-bg-install")'] = 'm.theme_bg_install()',

    -- remove.lua
    ['m.terminal_run("omarchy-pkg-remove")'] = 'm.pkg_remove()',

    -- update.lua
    ['m.terminal_run("omarchy-update")'] = 'm.update_system()',
}

local function process_file(filepath)
    local f = io.open(filepath, "r")
    if not f then
        print("Cannot open: " .. filepath)
        return false
    end
    local content = f:read("*a")
    f:close()

    local changed = false
    for old_str, new_str in pairs(replacements) do
        -- Escape special characters in old_str for gsub
        local escaped_old = old_str:gsub("([\"%[%]])", "%%%1")
        if content:find(old_str, 1, true) then
            print("  Replacing in " .. filepath .. ": '" .. old_str .. "' -> '" .. new_str .. "'")
            content = content:gsub(old_str, new_str, 1)
            changed = true
        end
    end

    if changed then
        local f_out = io.open(filepath, "w")
        if f_out then
            f_out:write(content)
            f_out:close()
            print("  Updated: " .. filepath)
            return true
        else
            print("  Failed to write: " .. filepath)
            return false
        end
    else
        print("  No changes: " .. filepath)
        return false
    end
end

local files = {
    "menus/install.lua",
    "menus/remove.lua",
    "menus/update.lua",
}

print("Fixing up hardcoded omarchy-* commands...")
for _, file in ipairs(files) do
    process_file(file)
end
print("Done.")
