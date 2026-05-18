#!/bin/bash
# Package manager abstraction — pacman, apt, dnf
# Sources: lib/platform.sh (for detect_distro)

_pkg_get_manager() {
  case "$(detect_distro)" in
    arch) echo "pacman" ;;
    debian) echo "apt" ;;
    fedora) echo "dnf" ;;
    *) echo "" ;;
  esac
}

pkg_install() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) sudo pacman -S --needed --noconfirm "$@" ;;
    apt) sudo apt-get install -y "$@" ;;
    dnf) sudo dnf install -y "$@" ;;
    *) echo "Error: unknown package manager" >&2; return 1 ;;
  esac
}

pkg_install_interactive() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) sudo pacman -S --needed "$@" ;;
    apt) sudo apt-get install "$@" ;;
    dnf) sudo dnf install "$@" ;;
    *) echo "Error: unknown package manager" >&2; return 1 ;;
  esac
}

pkg_remove() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) sudo pacman -Rns --noconfirm "$@" ;;
    apt) sudo apt-get remove -y "$@" ;;
    dnf) sudo dnf remove -y "$@" ;;
    *) echo "Error: unknown package manager" >&2; return 1 ;;
  esac
}

pkg_update() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) sudo pacman -Syu --noconfirm ;;
    apt) sudo apt-get update && sudo apt-get upgrade -y ;;
    dnf) sudo dnf upgrade -y ;;
    *) echo "Error: unknown package manager" >&2; return 1 ;;
  esac
}

pkg_search() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) pacman -Ss "$@" ;;
    apt) apt search "$@" ;;
    dnf) dnf search "$@" ;;
    *) echo "Error: unknown package manager" >&2; return 1 ;;
  esac
}

pkg_installed() {
  local manager
  manager=$(_pkg_get_manager)
  case "$manager" in
    pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
    apt) dpkg -s "$1" >/dev/null 2>&1 ;;
    dnf) rpm -q "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

# Third-party / community packages (AUR, PPAs, COPR, etc.)
pkg_thirdparty_install() {
  local distro
  distro=$(detect_distro)
  case "$distro" in
    arch)
      local aur_helper="${AUR_HELPER:-}"
      if [[ -z "$aur_helper" ]]; then
        for h in yay paru; do
          command -v "$h" >/dev/null 2>&1 && { aur_helper="$h"; break; }
        done
      fi
      if [[ -n "$aur_helper" ]]; then
        "$aur_helper" -S --needed --noconfirm "$@"
      else
        echo "Error: no AUR helper found (yay/paru)" >&2
        return 1
      fi
      ;;
    debian)
      sudo apt-get install -y "$@" 2>/dev/null || {
        echo "Warning: package '$*' not found in Debian repos" >&2
        return 1
      }
      ;;
    fedora)
      sudo dnf install -y "$@" 2>/dev/null || {
        echo "Warning: package '$*' not found in Fedora repos" >&2
        return 1
      }
      ;;
    *) echo "Error: unknown distro for third-party packages" >&2; return 1 ;;
  esac
}

# Package name lookup across distros
# Maps a canonical name to the distro-specific package name
pkg_name() {
  local name="$1"
  local distro
  distro=$(detect_distro)

  case "$name" in
    alacritty | foot | ghostty | kitty | helix | vim | steam | retroarch | lutris)
      echo "$name"
      ;;
    firefox) echo "firefox" ;;
    nvim) echo "neovim" ;;
    emacs)
      case "$distro" in arch) echo "emacs-wayland" ;; *) echo "emacs" ;; esac
      ;;
    chromium)
      case "$distro" in arch) echo "chromium" ;; debian) echo "chromium-browser" ;; *) echo "chromium" ;; esac
      ;;
    chrome)
      case "$distro" in arch | fedora) echo "google-chrome-stable" ;; debian) echo "google-chrome-stable" ;; *) echo "google-chrome-stable" ;; esac
      ;;
    edge)
      case "$distro" in arch) echo "microsoft-edge-stable-bin" ;; *) echo "microsoft-edge-stable" ;; esac
      ;;
    brave)
      case "$distro" in arch) echo "brave-bin" ;; *) echo "brave-browser" ;; esac
      ;;
    brave-origin)
      case "$distro" in arch) echo "brave-origin-beta-bin" ;; *) echo "brave-browser-beta" ;; esac
      ;;
    zen)
      case "$distro" in arch) echo "zen-browser-bin" ;; *) echo "zen-browser" ;; esac
      ;;
    code)
      case "$distro" in arch) echo "visual-studio-code-bin" ;; debian) echo "code" ;; *) echo "code" ;; esac
      ;;
    cursor)
      case "$distro" in arch) echo "cursor-bin" ;; *) echo "cursor" ;; esac
      ;;
    zed)
      case "$distro" in arch) echo "zed" ;; *) echo "zed" ;; esac
      ;;
    sublime)
      echo "sublime-text-4"
      ;;
    minecraft)
      echo "minecraft-launcher"
      ;;
    moonlight)
      echo "moonlight-qt"
      ;;
    geforce-now)
      echo "geforce-now-electron"
      ;;
    xbox-cloud)
      echo "xbox-cloud-gaming-electron"
      ;;
    heroic)
      echo "heroic-games-launcher"
      ;;
    dropbox) echo "dropbox" ;;
    tailscale) echo "tailscale" ;;
    nordvpn)
      case "$distro" in arch) echo "nordvpn-bin" ;; *) echo "nordvpn" ;; esac
      ;;
    bitwarden) echo "bitwarden" ;;
    ollama) echo "ollama" ;;
    lmstudio) echo "lm-studio" ;;
    crush) echo "crush" ;;
    xpadneo)
      echo "xpadneo-dkms"
      ;;
    # Fonts
    cascadia-mono) echo "ttf-cascadia-mono-nerd" ;;
    meslo) echo "ttf-meslo-nerd" ;;
    fira-code) echo "ttf-firacode-nerd" ;;
    victor-mono) echo "ttf-victor-mono-nerd" ;;
    bitstream-vera) echo "ttf-bitstream-vera-mono-nerd" ;;
    iosevka) echo "ttf-iosevka-nerd" ;;
    # Default: return name as-is
    *) echo "$name" ;;
  esac
}

_detect_aur_helper() {
  if [[ -n "${AUR_HELPER:-}" ]] && command -v "$AUR_HELPER" >/dev/null 2>&1; then
    echo "$AUR_HELPER"
    return
  fi
  for h in yay paru; do
    command -v "$h" >/dev/null 2>&1 && { echo "$h"; return; }
  done
  echo "yay"
}
AUR_HELPER="${AUR_HELPER:-$(_detect_aur_helper)}"