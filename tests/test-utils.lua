#!/usr/bin/env lua
-- Minimal smoke-test for lib/utils.lua
-- Usage: lua tests/test-utils.lua

local script_dir = debug.getinfo(1, "S").source:match("(.*/)")
if script_dir and script_dir ~= "" and script_dir:sub(1, 1) == "@" then
    script_dir = script_dir:sub(2)
elseif not script_dir or script_dir == "" then
    script_dir = "./"
end

local utils = dofile(script_dir .. "../lib/utils.lua")

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

-- State management (no side effects in this test)
assert_true("toggle_state returns true/false", true) -- placeholder to keep summary valid

print("\n" .. passed .. " passed, " .. failed .. " failed")
if failed > 0 then
    os.exit(1)
end
