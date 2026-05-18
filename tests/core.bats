#!/usr/bin/env bats
# Tests for lib/core.sh

setup() {
  export HOME="/tmp/omarchy-test-home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  mkdir -p "$HOME"

  # Mock platform detection
  detect_distro() { echo "arch"; }
  detect_wm() { echo "hyprland"; }
  wmenu_config_dir() { echo "$HOME/.config/wmenu"; }
  wmenu_data_dir() { echo "$HOME/.local/share/wmenu"; }

  # Mock package functions — pass through package name
  pkg_name() { echo "$1"; }
  pkg_install() { echo "pkg_install: $*"; }
  pkg_thirdparty_install() { echo "pkg_thirdparty_install: $*"; }
  font_set() { echo "font_set: $*"; }

  source "$(dirname "$BATS_TEST_DIRNAME")/lib/core.sh"
}

teardown() {
  rm -rf "/tmp/omarchy-test-home"
}

@test "terminal passes arguments through" {
  mock_path="$(mktemp -d)"
  cat >"$mock_path/foot" <<'MOCK'
#!/bin/bash
echo "args: $*"
MOCK
  chmod +x "$mock_path/foot"
  PATH="$mock_path:$PATH" run terminal echo hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"echo hello"* ]]
  rm -rf "$mock_path"
}

@test "terminal falls back to xdg-terminal-exec when no terminal found" {
  mock_path="$(mktemp -d)"
  cat >"$mock_path/xdg-terminal-exec" <<'MOCK'
#!/bin/bash
echo "args: $*"
MOCK
  chmod +x "$mock_path/xdg-terminal-exec"
  PATH="$mock_path:/usr/nonexistent" run terminal echo hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"echo hello"* ]]
  rm -rf "$mock_path"
}

@test "present_terminal executes command in terminal" {
  mock_path="$(mktemp -d)"
  cat >"$mock_path/foot" <<'MOCK'
#!/bin/bash
echo "running: $*"
MOCK
  chmod +x "$mock_path/foot"
  PATH="$mock_path:$PATH" run present_terminal "echo hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"echo hello"* ]]
  rm -rf "$mock_path"
}

@test "install generates correct command string" {
  present_terminal() { echo "present_terminal: $1"; }
  run install "TestApp" "test-pkg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test-pkg"* ]]
}

@test "install_and_launch generates correct command string" {
  present_terminal() { echo "present_terminal: $1"; }
  run install_and_launch "TestApp" "test-pkg" "test-desktop"
  [ "$status" -eq 0 ]
  [[ "$output" == *"test-pkg"* ]]
}

@test "install_font generates correct command string" {
  present_terminal() { echo "present_terminal: $1"; }
  run install_font "TestFont" "font-pkg" "Font Name"
  [ "$status" -eq 0 ]
  [[ "$output" == *"font-pkg"* ]]
}

@test "aur_install generates correct command string" {
  present_terminal() { echo "present_terminal: $1"; }
  run aur_install "TestApp" "aur-pkg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"aur-pkg"* ]]
}

@test "open_in_editor notifies and launches editor" {
  mock_path="$(mktemp -d)"
  cat >"$mock_path/notify-send" <<'MOCK'
#!/bin/bash
echo "notify: $*"
MOCK
  cat >"$mock_path/foot" <<'MOCK'
#!/bin/bash
echo "terminal: $*"
MOCK
  chmod +x "$mock_path/notify-send" "$mock_path/foot"
  EDITOR=nvim PATH="$mock_path:$PATH" run open_in_editor "/tmp/test.conf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Editing config file"* ]]
  [[ "$output" == *"nvim /tmp/test.conf"* ]]
  rm -rf "$mock_path"
}
