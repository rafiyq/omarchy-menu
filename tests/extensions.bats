#!/usr/bin/env bats
# Tests for lib/extensions.sh

setup() {
  export HOME="/tmp/wmenu-test-home"
  export XDG_CONFIG_HOME="$HOME/.config"
  mkdir -p "$HOME/.config/wmenu/extensions"

  # Mock wmenu_config_dir to match test home
  wmenu_config_dir() { echo "$HOME/.config/wmenu"; }
}

teardown() {
  rm -rf "/tmp/wmenu-test-home"
}

@test "load_user_extensions creates extensions directory" {
  rmdir "$HOME/.config/wmenu/extensions" 2>/dev/null || true
  rmdir "$HOME/.config/wmenu" 2>/dev/null || true
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/extensions.sh"
  [ -d "$HOME/.config/wmenu/extensions" ]
}

@test "load_user_extensions sources extension file if it exists" {
  echo 'TEST_EXTENSION_LOADED=1' >"$HOME/.config/wmenu/extensions/menu.sh"
  unset TEST_EXTENSION_LOADED
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/extensions.sh"
  [ "$TEST_EXTENSION_LOADED" = "1" ]
}

@test "load_user_extensions does not fail when no extension file" {
  rm -f "$HOME/.config/wmenu/extensions/menu.sh"
  run source "$(dirname "$BATS_TEST_DIRNAME")/lib/extensions.sh"
  [ "$status" -eq 0 ]
}

@test "extension file is sourced only once" {
  echo 'EXTENSION_COUNT=$((EXTENSION_COUNT+1))' >"$HOME/.config/wmenu/extensions/menu.sh"
  EXTENSION_COUNT=0
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/extensions.sh"
  [ "$EXTENSION_COUNT" -eq 1 ]
}
