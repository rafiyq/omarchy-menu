#!/usr/bin/env bats
# Tests for lib/menu.sh

setup() {
  export HOME="/tmp/omarchy-test-home"
  mkdir -p "$HOME"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/menu.sh"
}

teardown() {
  rm -rf "/tmp/omarchy-test-home"
}

@test "get_menu_backend defaults to walker" {
  unset OMARCHY_MENU_BACKEND
  run get_menu_backend
  [ "$output" = "walker" ]
}

@test "get_menu_backend respects OMARCHY_MENU_BACKEND env var" {
  OMARCHY_MENU_BACKEND=rofi run get_menu_backend
  [ "$output" = "rofi" ]
}

@test "get_menu_backend reads from config file" {
  unset OMARCHY_MENU_BACKEND
  mkdir -p "$HOME/.config/omarchy"
  echo "MENU_BACKEND=rofi" > "$HOME/.config/omarchy/menu.conf"
  run get_menu_backend
  [ "$output" = "rofi" ]
}

@test "get_menu_backend env var takes precedence over config file" {
  OMARCHY_MENU_BACKEND=walker
  mkdir -p "$HOME/.config/omarchy"
  echo "MENU_BACKEND=rofi" > "$HOME/.config/omarchy/menu.conf"
  run get_menu_backend
  [ "$output" = "walker" ]
}

@test "command_available returns true for existing commands" {
  run command_available bash
  [ "$status" -eq 0 ]
}

@test "command_available returns false for missing commands" {
  run command_available nonexistent_command_xyz_123
  [ "$status" -eq 1 ]
}

@test "menu delegates to show_menu" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/walker" <<'MOCK'
#!/bin/bash
echo "walker called: $*"
MOCK
  chmod +x "$mock_path/walker"
  PATH="$mock_path:$PATH" run menu "Test" "Option1\nOption2"
  [ "$status" -eq 0 ]
  [[ "$output" == *"walker called:"* ]]
  rm -rf "$mock_path"
}

@test "show_menu returns error for unknown backend" {
  OMARCHY_MENU_BACKEND=unknown_backend run show_menu "Test" "Options"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown menu backend"* ]]
}

@test "show_menu returns error when rofi not available and backend is rofi" {
  OMARCHY_MENU_BACKEND=rofi PATH="/usr/nonexistent" run show_menu "Test" "Options"
  [ "$status" -eq 1 ]
  [[ "$output" == *"rofi is not available"* ]]
}
