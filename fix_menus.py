#!/usr/bin/env python3
"""Replace hardcoded omarchy-* commands in menus/*.lua with proper lib/utils.lua function calls."""

import re
import pathlib

COMMANDS = {
    # install.lua
    'omarchy-pkg-install': 'm.pkg_install()',
    'omarchy-pkg-aur-install': 'm.pkg_aur_install()',
    'omarchy-theme-install': 'm.theme_install()',
    'omarchy-theme-bg-install': 'm.theme_bg_install()',

    # remove.lua
    'omarchy-pkg-remove': 'm.pkg_remove()',

    # update.lua
    'omarchy-update': 'm.update_system()',
}

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    changed = False
    for old_cmd, new_call in COMMANDS.items():
        # Match m.terminal_run("omarchy-something")
        pattern = 'm\\.terminal_run\\("' + old_cmd + '"\\)'
        if re.search(pattern, content):
            content = re.sub(pattern, new_call, content)
            print(f"  Replaced in {filepath}: {old_cmd} -> {new_call}")
            changed = True

    if changed:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  Updated: {filepath}")
    else:
        print(f"  No changes: {filepath}")

if __name__ == "__main__":
    files = [
        "menus/install.lua",
        "menus/remove.lua",
        "menus/update.lua",
    ]

    print("Replacing hardcoded omarchy-* commands in menus/*.lua...")
    for file in files:
        fix_file(file)
    print("Done.")
