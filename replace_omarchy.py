#!/usr/bin/env python3
"""Replace omarchy-* script names with proper utils.lua function calls."""

import os

COMMANDS = {
    'omarchy-pkg-install': 'm.pkg_install()',
    'omarchy-pkg-aur-install': 'm.pkg_aur_install()',
    'omarchy-pkg-remove': 'm.pkg_remove()',
    'omarchy-update': 'm.update_system()',
    'omarchy-theme-install': 'm.theme_install()',
    'omarchy-theme-bg-install': 'm.theme_bg_install()',
}

def fix_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    changed = False
    for old_cmd, new_call in COMMANDS.items():
        if old_cmd in content:
            content = content.replace(old_cmd, new_call)
            print(f"  Replaced: {old_cmd}")
            changed = True

    if changed:
        with open(filename, 'w') as f:
            f.write(content)
        print(f"  Updated: {filename}")
    else:
        print(f"  No changes: {filename}")

if __name__ == "__main__":
    files = ["menus/install.lua", "menus/remove.lua", "menus/update.lua"]
    print("Replacing omarchy-* commands...")
    for fname in files:
        fix_file(fname)
    print("Done.")
