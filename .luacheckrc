-- Luacheck configuration for omarchy-menu Lua providers and shared library

std = "lua51"

files = {
    ["menus/*.lua"] = {
        globals = {
            "Name", "NamePretty", "Icon", "FixedOrder",
            "HideFromProviderlist", "Cache", "Action", "Parent", "SubMenu",
            "GetEntries",
        },
        read_globals = {
            "os", "io", "table", "string", "math", "debug",
            "pcall", "dofile", "require", "loadfile", "setfenv",
            "tonumber", "tostring", "type",
        },
    },
    ["lib/utils.lua"] = {
        read_globals = {
            "os", "io", "table", "string", "math",
            "tonumber", "tostring", "type",
        },
    },
}

max_line_length = 120
