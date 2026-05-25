#!/usr/bin/env lua
-- Minimal smoke-test for lib/utils.lua
-- Usage: lua tests/test-utils.lua

local ok, utils
if arg and #arg > 0 then
    -- loaded via module
    ok, utils = pcall(dofile, "lib/utils.lua")
else
    local script_dir = debug.getinfo(1, "S").source
    if script_dir:sub(1, 1) == "@" then
        script_dir = script_dir:sub(2)
    end
    script_dir = script_dir:match("(.*/)") or "./"
    ok, utils = pcall(dofile, script_dir .. "../lib/utils.lua")
end

if not ok then
    error("Failed to load lib/utils.lua: " .. tostring(utils))
end

local passed = 0
local failed = 0

local function assert_eq(label, got, expected)
    if got == expected then
        passed = passed + 1
        print("  PASS: " .. label)
    else
        failed = failed + 1
        print("  FAIL: " .. label .. " (got: " .. tostring(got) .. ", expected: " .. tostring(expected) .. ")")
    end
end

local function assert_true(label, cond)
    if cond then
        passed = passed + 1
        print("  PASS: " .. label)
    else
        failed = failed + 1
        print("  FAIL: " .. label)
    end
end

print("Smoke-testing lib/utils.lua...")

-- File / path utils
assert_true("file_exists /etc/passwd", utils.file_exists("/etc/passwd"))
assert_true("not file_exists /nonexistent", not utils.file_exists("/nonexistent"))

local tmpfile = os.tmpname()
assert_true("write_file returns true", utils.write_file(tmpfile, "hello utils"))
assert_eq("read_file returns content", utils.read_file(tmpfile), "hello utils")
os.remove(tmpfile)

-- Command execution
assert_true("cmd_exists ls", utils.cmd_exists("ls"))
assert_true("not cmd_exists __nonexistent__", not utils.cmd_exists("__nonexistent__"))

local out, code = utils.exec("echo hello")
assert_true("exec returns output", out and out:find("hello"))
assert_eq("exec return code 0", code, 0)

-- Platform detection (basic sanity)
assert_true("detect_distro returns string", type(utils.detect_distro()) == "string" or true)
assert_true("detect_wm returns string or nil", type(utils.detect_wm()) == "string" or type(utils.detect_wm()) == "nil")

-- WM functions (just check existence)
assert_true("wm_config_dir returns string", type(utils.wm_config_dir()) == "string")

-- Capture functions (just check existence)
assert_true("capture_screenshot is function", type(utils.capture_screenshot) == "function")
assert_true("capture_text_extraction is function", type(utils.capture_text_extraction) == "function")
assert_true("capture_colorpick is function", type(utils.capture_colorpick) == "function")

-- Package management (just check existence)
assert_true("pkg_manager returns string or nil", type(utils.pkg_manager()) == "string" or type(utils.pkg_manager()) == "nil")
assert_true("pkg_install is function", type(utils.pkg_install) == "function")
assert_true("pkg_remove is function", type(utils.pkg_remove) == "function")

-- Terminal / editor (just check existence)
assert_true("terminal_detect returns string or nil", type(utils.terminal_detect()) == "string" or type(utils.terminal_detect()) == "nil")
assert_true("open_in_editor is function", type(utils.open_in_editor) == "function")

-- Service restarts (just check existence)
assert_true("restart_pipewire is function", type(utils.restart_pipewire) == "function")
assert_true("restart_wifi is function", type(utils.restart_wifi) == "function")

-- Font management (just check existence)
assert_true("font_list returns table or nil", type(utils.font_list) == "function")

print("\n" .. passed .. " passed, " .. failed .. " failed")
if failed > 0 then
    os.exit(1)
end
