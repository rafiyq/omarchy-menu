#!/usr/bin/env bats
# Tests for lib/navigation.sh

setup() {
  export HOME="/tmp/omarchy-test-home"
  mkdir -p "$HOME"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/core.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/menu.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/navigation.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/apps.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/learn.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/trigger.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/style.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/setup.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/install.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/remove.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/update.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/about.sh"
  source "$(dirname "$BATS_TEST_DIRNAME")/modules/system.sh"
  show_main_menu() { echo "main menu"; }
}

teardown() {
  rm -rf "/tmp/omarchy-test-home"
}

@test "back_to exits when BACK_TO_EXIT is true" {
  BACK_TO_EXIT=true
  run back_to show_main_menu
  [ "$status" -eq 0 ]
}

@test "back_to calls parent menu when BACK_TO_EXIT is false" {
  BACK_TO_EXIT=false
  run back_to show_main_menu
  [ "$output" = "main menu" ]
}

@test "go_to_menu routes apps to show_apps_menu" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/walker" <<'MOCK'
#!/bin/bash
echo "apps menu launched"
MOCK
  chmod +x "$mock_path/walker"
  PATH="$mock_path:$PATH" run go_to_menu "Apps"
  [[ "$output" == *"apps menu launched"* ]]
  rm -rf "$mock_path"
}

@test "go_to_menu routes style to show_style_menu" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/walker" <<'MOCK'
#!/bin/bash
echo "󰸌 Theme"
MOCK
  cat > "$mock_path/omarchy-launch-walker" <<'MOCK'
#!/bin/bash
echo "theme walker launched"
MOCK
  chmod +x "$mock_path/walker" "$mock_path/omarchy-launch-walker"
  PATH="$mock_path:$PATH" run go_to_menu "Style"
  [[ "$output" == *"theme walker launched"* ]]
  rm -rf "$mock_path"
}

@test "go_to_menu routes about to show_about" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/walker" <<'MOCK'
#!/bin/bash
echo "󰋶 Omarchy"
MOCK
  cat > "$mock_path/omarchy-launch-about" <<'MOCK'
#!/bin/bash
echo "about launched"
MOCK
  chmod +x "$mock_path/walker" "$mock_path/omarchy-launch-about"
  PATH="$mock_path:$PATH" run go_to_menu "About"
  [[ "$output" == *"about launched"* ]]
  rm -rf "$mock_path"
}

@test "go_to_menu routes system to show_system_menu" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/walker" <<'MOCK'
#!/bin/bash
echo "󱄄 Screensaver"
MOCK
  cat > "$mock_path/omarchy-launch-screensaver" <<'MOCK'
#!/bin/bash
echo "screensaver launched"
MOCK
  cat > "$mock_path/omarchy-toggle-enabled" <<'MOCK'
#!/bin/bash
echo "toggle"
MOCK
  cat > "$mock_path/omarchy-hibernation-available" <<'MOCK'
#!/bin/bash
false
MOCK
  chmod +x "$mock_path/walker" "$mock_path/omarchy-launch-screensaver" \
    "$mock_path/omarchy-toggle-enabled" "$mock_path/omarchy-hibernation-available"
  PATH="$mock_path:$PATH" run go_to_menu "System"
  [[ "$output" == *"screensaver launched"* ]]
  rm -rf "$mock_path"
}

@test "BACK_TO_EXIT defaults to false" {
  [ "$BACK_TO_EXIT" = "false" ]
}
