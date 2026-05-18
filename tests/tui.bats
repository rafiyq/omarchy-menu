#!/usr/bin/env bats
# Tests for lib/tui.sh

setup() {
  export HOME="/tmp/omarchy-test-home"
  mkdir -p "$HOME"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/tui.sh"
}

teardown() {
  rm -rf "/tmp/omarchy-test-home"
}

@test "_tui_term_height returns default when not a terminal" {
  run _tui_term_height
  [ "$output" = "24" ]
}

@test "_tui_term_width returns default when not a terminal" {
  run _tui_term_width
  [ "$output" = "80" ]
}

@test "_tui_term_height uses LINES env var" {
  LINES=50 run _tui_term_height
  [ "$output" = "50" ]
}

@test "_tui_term_width uses COLUMNS env var" {
  COLUMNS=120 run _tui_term_width
  [ "$output" = "120" ]
}

@test "tui_menu function exists" {
  declare -f tui_menu >/dev/null
}

@test "tui_input function exists" {
  declare -f tui_input >/dev/null
}

@test "_tui_save_termios does not fail on non-terminal" {
  run _tui_save_termios
  [ "$status" -eq 0 ]
}

@test "_tui_restore_termios does not fail when nothing saved" {
  run _tui_restore_termios
  [ "$status" -eq 0 ]
}
