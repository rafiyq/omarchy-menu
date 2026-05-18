#!/bin/bash
# Pure bash TUI menu — no external dependencies beyond bash
# Uses ANSI escape codes for rendering and read for input

# Save and restore terminal state
_tui_saved_termios=""

_tui_save_termios() {
  if [[ -t 0 ]]; then
    _tui_saved_termios=$(stty -g 2>/dev/null) || true
    stty -echo -icanon min 1 time 0 2>/dev/null || true
  fi
}

_tui_restore_termios() {
  if [[ -n "$_tui_saved_termios" ]]; then
    stty "$_tui_saved_termios" 2>/dev/null || true
    _tui_saved_termios=""
  fi
}

# Get terminal size
_tui_term_height() {
  if [[ -n "${LINES:-}" ]]; then
    echo "$LINES"
  elif [[ -t 0 ]] && command -v stty >/dev/null 2>&1; then
    stty size 2>/dev/null | cut -d' ' -f1
  else
    echo 24
  fi
}

_tui_term_width() {
  if [[ -n "${COLUMNS:-}" ]]; then
    echo "$COLUMNS"
  elif [[ -t 0 ]] && command -v stty >/dev/null 2>&1; then
    stty size 2>/dev/null | cut -d' ' -f2
  else
    echo 80
  fi
}

# Render the TUI menu
# Usage: tui_menu "Prompt" "Option1\nOption2\nOption3"
# Returns: selected option text on stdout
tui_menu() {
  local prompt="$1"
  local options_raw="$2"
  local extra="${3:-}"

  # Parse options into array
  local -a options=()
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] && options+=("$line")
  done <<<"$(echo -e "$options_raw")"

  local count=${#options[@]}
  if ((count == 0)); then
    echo "Error: no options provided" >&2
    return 1
  fi

  local selected=0
  local scroll_offset=0
  local term_height
  term_height=$(_tui_term_height)
  local visible=$((term_height - 4))
  if ((visible < 1)); then
    visible=1
  fi
  if ((visible > count)); then
    visible=$count
  fi

  # Filter support
  local filter=""
  local -a filtered_indices=()
  local use_filter=false

  # Check if filtering is requested via extra args
  if [[ "$extra" == *"--filter"* ]]; then
    use_filter=true
  fi

  _tui_build_filtered() {
    filtered_indices=()
    if [[ -z "$filter" ]]; then
      local i
      for ((i = 0; i < count; i++)); do
        filtered_indices+=("$i")
      done
    else
      local i
      for ((i = 0; i < count; i++)); do
        if [[ "${options[$i],,}" == *"${filter,,}"* ]]; then
          filtered_indices+=("$i")
        fi
      done
    fi
  }

  _tui_build_filtered

  _tui_render() {
    local fc=${#filtered_indices[@]}
    if ((fc == 0)); then
      fc=1
    fi

    # Adjust scroll offset
    if ((selected < scroll_offset)); then
      scroll_offset=$selected
    elif ((selected >= scroll_offset + visible)); then
      scroll_offset=$((selected - visible + 1))
    fi
    if ((scroll_offset + visible > fc)); then
      scroll_offset=$((fc - visible))
    fi
    if ((scroll_offset < 0)); then
      scroll_offset=0
    fi

    # Clear screen and move cursor home
    printf '\033[H\033[2J'

    # Prompt
    printf '\033[1;36m%s\033[0m\n' "$prompt"
    if ((use_filter)) && [[ -n "$filter" ]]; then
      printf '\033[33m  filter: %s\033[0m\n' "$filter"
    fi
    printf '\033[90m  ────────────────────────────────\033[0m\n'

    # Options
    local i
    for ((i = scroll_offset; i < scroll_offset + visible && i < fc; i++)); do
      local idx=${filtered_indices[$i]}
      local opt="${options[$idx]}"
      if ((i == selected)); then
        printf '\033[7m  %s\033[0m\n' " $opt "
      else
        printf '  %s\n' "$opt"
      fi
    done

    # Footer
    printf '\033[90m  ────────────────────────────────\033[0m\n'
    if ((use_filter)); then
      printf '\033[90m  ↑↓ navigate  Enter select  Esc back  type to filter\033[0m\n'
    else
      printf '\033[90m  ↑↓ navigate  Enter select  Esc/q back\033[0m\n'
    fi
  }

  _tui_render

  trap '_tui_restore_termios' EXIT
  _tui_save_termios

  while true; do
    local key=""
    read -rsn3 key 2>/dev/null || true

    # Handle escape sequences
    case "$key" in
      $'\033[A' | $'\033OA') # Up
        if ((selected > 0)); then
          ((selected--))
          _tui_render
        fi
        ;;
      $'\033[B' | $'\033OB') # Down
        if ((selected < ${#filtered_indices[@]} - 1)); then
          ((selected++))
          _tui_render
        fi
        ;;
      "") # Single char (no escape prefix)
        if [[ -n "$key" ]]; then
          local c="$key"
          case "$c" in
            $'\n' | "") # Enter
              _tui_restore_termios
              trap - EXIT
              if ((${#filtered_indices[@]} > 0)); then
                echo "${options[${filtered_indices[$selected]}]}"
                return 0
              fi
              return 1
              ;;
            $'\033' | 'q') # Escape or q
              _tui_restore_termios
              trap - EXIT
              return 1
              ;;
            *)
              if $use_filter; then
                filter+="$c"
                selected=0
                scroll_offset=0
                _tui_build_filtered
                _tui_render
              fi
              ;;
          esac
        fi
        ;;
      $'\033') # Escape prefix, need more chars
        read -rsn2 key2 2>/dev/null || true
        key="$key$key2"
        case "$key" in
          $'\033[A' | $'\033OA') # Up
            if ((selected > 0)); then
              ((selected--))
              _tui_render
            fi
            ;;
          $'\033[B' | $'\033OB') # Down
            if ((selected < ${#filtered_indices[@]} - 1)); then
              ((selected++))
              _tui_render
            fi
            ;;
          $'\033[D' | $'\033OD') # Left (delete filter char)
            if $use_filter && [[ -n "$filter" ]]; then
              filter="${filter%?}"
              selected=0
              scroll_offset=0
              _tui_build_filtered
              _tui_render
            fi
            ;;
          $'\033[3~') # Delete (clear filter)
            if $use_filter; then
              filter=""
              selected=0
              scroll_offset=0
              _tui_build_filtered
              _tui_render
            fi
            ;;
          *)
            # Could be escape key alone
            _tui_restore_termios
            trap - EXIT
            return 1
            ;;
        esac
        ;;
      $'\7f' | $'\033[D' | $'\033OD') # Backspace / Left
        if $use_filter && [[ -n "$filter" ]]; then
          filter="${filter%?}"
          selected=0
          scroll_offset=0
          _tui_build_filtered
          _tui_render
        fi
        ;;
    esac
  done
}

# TUI input prompt — replacement for rofi/walker input
# Usage: tui_input "Prompt text"
tui_input() {
  local prompt="$1"

  printf '\033[1;36m%s\033[0m ' "$prompt"

  trap '_tui_restore_termios' EXIT
  _tui_save_termios

  local input=""
  while true; do
    local char=""
    read -rsn1 char 2>/dev/null || true

    case "$char" in
      $'\n' | "")
        _tui_restore_termios
        trap - EXIT
        echo "$input"
        return 0
        ;;
      $'\033')
        read -rsn2 _rest 2>/dev/null || true
        _tui_restore_termios
        trap - EXIT
        echo "$input"
        return 1
        ;;
      $'\7f')
        input="${input%?}"
        printf '\r\033[K\033[1;36m%s\033[0m %s' "$prompt" "$input"
        ;;
      *)
        input+="$char"
        printf '\r\033[K\033[1;36m%s\033[0m %s' "$prompt" "$input"
        ;;
    esac
  done
}
