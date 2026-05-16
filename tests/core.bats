#!/usr/bin/env bats
# Tests for lib/core.sh

setup() {
  export HOME="/tmp/omarchy-test-home"
  mkdir -p "$HOME"
  source "$(dirname "$BATS_TEST_DIRNAME")/lib/core.sh"
}

teardown() {
  rm -rf "/tmp/omarchy-test-home"
}

@test "terminal passes arguments through" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/xdg-terminal-exec" <<'MOCK'
#!/bin/bash
echo "args: $*"
MOCK
  chmod +x "$mock_path/xdg-terminal-exec"
  PATH="$mock_path:$PATH" run terminal echo hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"echo hello"* ]]
  rm -rf "$mock_path"
}

@test "install generates correct command string" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/omarchy-launch-floating-terminal-with-presentation" <<'MOCK'
#!/bin/bash
echo "cmd: $1"
MOCK
  chmod +x "$mock_path/omarchy-launch-floating-terminal-with-presentation"
  PATH="$mock_path:$PATH" run install "TestApp" "test-pkg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"omarchy-pkg-add 'test-pkg'"* ]]
  rm -rf "$mock_path"
}

@test "install_and_launch generates correct command string" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/omarchy-launch-floating-terminal-with-presentation" <<'MOCK'
#!/bin/bash
echo "cmd: $1"
MOCK
  chmod +x "$mock_path/omarchy-launch-floating-terminal-with-presentation"
  PATH="$mock_path:$PATH" run install_and_launch "TestApp" "test-pkg" "test-desktop"
  [ "$status" -eq 0 ]
  [[ "$output" == *"omarchy-pkg-add 'test-pkg'"* ]]
  [[ "$output" == *"gtk-launch 'test-desktop'"* ]]
  rm -rf "$mock_path"
}

@test "install_font generates correct command string" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/omarchy-launch-floating-terminal-with-presentation" <<'MOCK'
#!/bin/bash
echo "cmd: $1"
MOCK
  chmod +x "$mock_path/omarchy-launch-floating-terminal-with-presentation"
  PATH="$mock_path:$PATH" run install_font "TestFont" "font-pkg" "Font Name"
  [ "$status" -eq 0 ]
  [[ "$output" == *"omarchy-pkg-add 'font-pkg'"* ]]
  [[ "$output" == *"omarchy-font-set 'Font Name'"* ]]
  rm -rf "$mock_path"
}

@test "aur_install generates correct command string" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/omarchy-launch-floating-terminal-with-presentation" <<'MOCK'
#!/bin/bash
echo "cmd: $1"
MOCK
  chmod +x "$mock_path/omarchy-launch-floating-terminal-with-presentation"
  PATH="$mock_path:$PATH" run aur_install "TestApp" "aur-pkg"
  [ "$status" -eq 0 ]
  [[ "$output" == *"omarchy-pkg-aur-add 'aur-pkg'"* ]]
  rm -rf "$mock_path"
}

@test "open_in_editor notifies and launches editor" {
  mock_path="$(mktemp -d)"
  cat > "$mock_path/notify-send" <<'MOCK'
#!/bin/bash
echo "notify: $*"
MOCK
  cat > "$mock_path/omarchy-launch-editor" <<'MOCK'
#!/bin/bash
echo "editor: $*"
MOCK
  chmod +x "$mock_path/notify-send" "$mock_path/omarchy-launch-editor"
  PATH="$mock_path:$PATH" run open_in_editor "/tmp/test.conf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Editing config file"* ]]
  [[ "$output" == *"editor: /tmp/test.conf"* ]]
  rm -rf "$mock_path"
}
