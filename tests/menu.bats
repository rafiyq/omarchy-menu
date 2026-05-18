#!/usr/bin/env bats
# Tests for lib/menu.sh

setup() {
  export HOME="/tmp/wmenu-test-home"
  mkdir -p "$HOME"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/tui.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/menu.sh"
}

teardown() {
  rm -rf "/tmp/wmenu-test-home"
}

@test "get_menu_backend defaults to tui when no GUI backend available" {
  PATH="/usr/nonexistent" run get_menu_backend
  [ "$output" = "tui" ]
}

@test "get_menu_backend prefers walker when available" {
  mock_path="$(mktemp -d)"
  touch "$mock_path/walker"
  chmod +x "$mock_path/walker"
  PATH="$mock_path:/usr/nonexistent" run get_menu_backend
  [ "$output" = "walker" ]
  rm -rf "$mock_path"
}

@test "get_menu_backend falls back to rofi when walker unavailable" {
  mock_path="$(mktemp -d)"
  touch "$mock_path/rofi"
  chmod +x "$mock_path/rofi"
  PATH="$mock_path:/usr/nonexistent" run get_menu_backend
  [ "$output" = "rofi" ]
  rm -rf "$mock_path"
}

@test "get_menu_backend respects MENU_BACKEND env var" {
  MENU_BACKEND=rofi run get_menu_backend
  [ "$output" = "rofi" ]
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
  cat >"$mock_path/walker" <<'MOCK'
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
  MENU_BACKEND=unknown_backend run show_menu "Test" "Options"
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown menu backend"* ]]
}

@test "show_menu returns error when rofi not available and backend is rofi" {
  MENU_BACKEND=rofi PATH="/usr/nonexistent" run show_menu "Test" "Options"
  [ "$status" -eq 1 ]
  [[ "$output" == *"rofi is not available"* ]]
}

@test "show_menu routes to tui_menu for tui backend" {
  # Verify the case statement routes correctly by checking function resolution
  MENU_BACKEND=tui run bash -c '
    source "'"$(dirname "$BATS_TEST_DIRNAME")/lib/tui.sh"'"
    source "'"$(dirname "$BATS_TEST_DIRNAME")/lib/menu.sh"'"
    # Override tui_menu to capture that it was called
    tui_menu() { echo "tui_menu called with: $1"; return 0; }
    show_menu "Test" "Option1"
  '
  [ "$status" -eq 0 ]
  [[ "$output" == *"tui_menu called with: Test"* ]]
}
