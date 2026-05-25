#!/usr/bin/env lua
-- Minimal smoke-test for all menu providers
-- Usage: lua tests/test-providers.lua

local script_dir = debug.getinfo(1, "S").source
if script_dir:sub(1, 1) == "@" then
    script_dir = script_dir:sub(2)
end
script_dir = script_dir:match("(.*/)") or "./"

local menus_dir = script_dir .. "../menus/"

local providers = {
    "start", "system", "style", "setup",
    "install", "remove", "update", "capture", "trigger",
}

local passed = 0
local failed = 0

for _, name in ipairs(providers) do
    io.write("Testing " .. name .. ".lua ... ")
    local path = menus_dir .. name .. ".lua"
    local chunk, err = loadfile(path)
    if not chunk then
        failed = failed + 1
        print("FAIL (compile): " .. tostring(err))
        goto continue
    end

    -- Create a clean environment for the provider
    local env = {}
    setmetatable(env, { __index = _G })
    setfenv(chunk, env)

    local ok, load_err = pcall(chunk)
    if not ok then
        failed = failed + 1
        print("FAIL (execute): " .. tostring(load_err))
        goto continue
    end

    if not env.GetEntries or type(env.GetEntries) ~= "function" then
        failed = failed + 1
        print("FAIL (missing GetEntries)")
        goto continue
    end

    local ok2, entries = pcall(env.GetEntries)
    if not ok2 then
        failed = failed + 1
        print("FAIL (GetEntries error): " .. tostring(entries))
        goto continue
    end

    if type(entries) ~= "table" or #entries == 0 then
        failed = failed + 1
        print("FAIL (empty entries)")
        goto continue
    end

    -- Validate each entry has the required fields
    local valid = true
    for i, entry in ipairs(entries) do
        if not entry.Text or #entry.Text == 0 then
            valid = false
            print("FAIL (entry " .. i .. " missing Text)")
            break
        end
    end

    if valid then
        passed = passed + 1
        print("PASS (" .. #entries .. " entries)")
    else
        failed = failed + 1
    end

    ::continue::
end

print("\n" .. passed .. " passed, " .. failed .. " failed")
if failed > 0 then
    os.exit(1)
end
