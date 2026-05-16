#!/bin/bash
# Installation menus functions

show_install_menu() {
  case $(menu "Install" "󰣇  Package\n󰣇  AUR\n  Web App\n  TUI\n  Service\n  Style\n󰵮  Development\n  Editor\n  Terminal\n  Browser\n󱚤  AI\n  Gaming\n󰍲  Windows") in
    *Package*) terminal omarchy-pkg-install ;;
    *AUR*) terminal omarchy-pkg-aur-install ;;
    *Web*) present_terminal omarchy-webapp-install ;;
    *TUI*) present_terminal omarchy-tui-install ;;
    *Service*) show_install_service_menu ;;
    *Style*) show_install_style_menu ;;
    *Development*) show_install_development_menu ;;
    *Editor*) show_install_editor_menu ;;
    *Terminal*) show_install_terminal_menu ;;
    *Browser*) show_install_browser_menu ;;
    *Gaming*) show_install_gaming_menu ;;
    *AI*) show_install_ai_menu ;;
    *Windows*) present_terminal "omarchy-windows-vm install" ;;
    *) back_to show_main_menu ;;
  esac
}

show_install_browser_menu() {
  case $(menu "Install" " Chrome\n Edge\n Brave\n Brave Origin\n Firefox\n󰖟 Zen") in
    *Chrome*) present_terminal "omarchy-install-browser chrome" ;;
    *Edge*) present_terminal "omarchy-install-browser edge" ;;
    *"Brave Origin"*) present_terminal "omarchy-install-browser brave-origin" ;;
    *Brave*) present_terminal "omarchy-install-browser brave" ;;
    *Firefox*) present_terminal "omarchy-install-browser firefox" ;;
    *Zen*) present_terminal "omarchy-install-browser zen" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_service_menu() {
  case $(menu "Install" " Dropbox\n Tailscale\n󱇱 NordVPN [AUR]\n󰏖 ONCE\n󰟵 Bitwarden\n Chromium Account") in
    *Dropbox*) present_terminal omarchy-install-dropbox ;;
    *Tailscale*) present_terminal omarchy-install-tailscale ;;
    *NordVPN*) present_terminal omarchy-install-nordvpn ;;
    *ONCE*) present_terminal omarchy-install-once ;;
    *Bitwarden*) install_and_launch "Bitwarden" "bitwarden bitwarden-cli" "bitwarden" ;;
    *Chromium*) present_terminal omarchy-install-chromium-google-account ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_editor_menu() {
  case $(menu "Install" " VSCode\n Cursor\n Zed\n Sublime Text\n Helix\n Vim\n Emacs") in
    *VSCode*) present_terminal omarchy-install-vscode ;;
    *Cursor*) install_and_launch "Cursor" "cursor-bin" "cursor" ;;
    *Zed*) present_terminal omarchy-install-zed ;;
    *Sublime*) install_and_launch "Sublime Text" "sublime-text-4" "sublime_text" ;;
    *Helix*) present_terminal omarchy-install-helix ;;
    *Vim*) install "Vim" "vim" ;;
    *Emacs*) install "Emacs" "emacs-wayland" && systemctl --user enable --now emacs.service ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_terminal_menu() {
  case $(menu "Install" " Alacritty\n Foot\n Ghostty\n Kitty") in
    *Alacritty*) install_terminal "alacritty" ;;
    *Foot*) install_terminal "foot" ;;
    *Ghostty*) install_terminal "ghostty" ;;
    *Kitty*) install_terminal "kitty" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_ai_menu() {
  ollama_pkg=$(
    (omarchy-cmd-present nvidia-smi && echo ollama-cuda) ||
      (omarchy-cmd-present rocminfo && echo ollama-rocm) ||
      echo ollama
  )

  case $(menu "Install" " Dictation\n󱚤 LM Studio\n󱚤 Ollama\n󱚤 Crush") in
    *Dictation*) present_terminal omarchy-voxtype-install ;;
    *Studio*) install "LM Studio" "lmstudio-bin" ;;
    *Ollama*) install "Ollama" "$ollama_pkg" ;;
    *Crush*) install "Crush" "crush-bin" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_gaming_menu() {
  case $(menu "Install" " Steam\n RetroArch\n󰍳 Minecraft\n󰢹 NVIDIA GeForce NOW\n Xbox Cloud Gaming\n󰂯 Xbox Controller\n󰍹 Moonlight (GameStream)\n Lutris (Battle.net)\n󱓟 Heroic (Epic Games)") in
    *Steam*) present_terminal omarchy-install-gaming-steam ;;
    *RetroArch*) present_terminal omarchy-install-gaming-retroarch ;;
    *Minecraft*) install_and_launch "Minecraft" "minecraft-launcher" "minecraft-launcher" ;;
    *GeForce*) present_terminal omarchy-install-gaming-geforce-now ;;
    *"Xbox Cloud"*) present_terminal omarchy-install-gaming-xbox-cloud ;;
    *Xbox*) present_terminal omarchy-install-gaming-xbox-controllers ;;
    *Lutris*) present_terminal omarchy-install-gaming-lutris ;;
    *Heroic*) present_terminal omarchy-install-gaming-heroic ;;
    *Moonlight*) present_terminal omarchy-install-gaming-moonlight ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_style_menu() {
  case $(menu "Install" "󰸌 Theme\n Background\n Font") in
    *Theme*) present_terminal omarchy-theme-install ;;
    *Background*) omarchy-theme-bg-install ;;
    *Font*) show_install_font_menu ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_font_menu() {
  case $(menu "Install" " Cascadia Mono\n Meslo LG Mono\n Fira Code\n Victor Code\n Bitstream Vera Mono\n Iosevka" "--width 350") in
    *Cascadia*) install_font "Cascadia Mono" "ttf-cascadia-mono-nerd" "CaskaydiaMono Nerd Font" ;;
    *Meslo*) install_font "Meslo LG Mono" "ttf-meslo-nerd" "MesloLGL Nerd Font" ;;
    *Fira*) install_font "Fira Code" "ttf-firacode-nerd" "FiraCode Nerd Font" ;;
    *Victor*) install_font "Victor Code" "ttf-victor-mono-nerd" "VictorMono Nerd Font" ;;
    *Bitstream*) install_font "Bitstream Vera Code" "ttf-bitstream-vera-mono-nerd" "BitstromWera Nerd Font" ;;
    *Iosevka*) install_font "Iosevka" "ttf-iosevka-nerd" "Iosevka Nerd Font Mono" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_development_menu() {
  case $(menu "Install" "󰫏 Ruby on Rails\n Docker DB\n JavaScript\n Go\n PHP\n Python\n Elixir\n Zig\n Rust\n Java\n .NET\n OCaml\n Clojure\n Scala") in
    *Rails*) present_terminal "omarchy-install-dev-env ruby" ;;
    *Docker*) present_terminal omarchy-install-docker-dbs ;;
    *JavaScript*) show_install_javascript_menu ;;
    *Go*) present_terminal "omarchy-install-dev-env go" ;;
    *PHP*) show_install_php_menu ;;
    *Python*) present_terminal "omarchy-install-dev-env python" ;;
    *Elixir*) show_install_elixir_menu ;;
    *Zig*) present_terminal "omarchy-install-dev-env zig" ;;
    *Rust*) present_terminal "omarchy-install-dev-env rust" ;;
    *Java*) present_terminal "omarchy-install-dev-env java" ;;
    *NET*) present_terminal "omarchy-install-dev-env dotnet" ;;
    *OCaml*) present_terminal "omarchy-install-dev-env ocaml" ;;
    *Clojure*) present_terminal "omarchy-install-dev-env clojure" ;;
    *Scala*) present_terminal "omarchy-install-dev-env scala" ;;
    *) back_to show_install_menu ;;
  esac
}

show_install_javascript_menu() {
  case $(menu "Install" " Node.js\n Bun\n Deno") in
    *Node*) present_terminal "omarchy-install-dev-env node" ;;
    *Bun*) present_terminal "omarchy-install-dev-env bun" ;;
    *Deno*) present_terminal "omarchy-install-dev-env deno" ;;
    *) back_to show_install_development_menu ;;
  esac
}

show_install_php_menu() {
  case $(menu "Install" " PHP\n Laravel\n Symfony") in
    *PHP*) present_terminal "omarchy-install-dev-env php" ;;
    *Laravel*) present_terminal "omarchy-install-dev-env laravel" ;;
    *Symfony*) present_terminal "omarchy-install-dev-env symfony" ;;
    *) back_to show_install_development_menu ;;
  esac
}

show_install_elixir_menu() {
  case $(menu "Install" " Elixir\n Phoenix") in
    *Elixir*) present_terminal "omarchy-install-dev-env elixir" ;;
    *Phoenix*) present_terminal "omarchy-install-dev-env phoenix" ;;
    *) back_to show_install_development_menu ;;
  esac
}

show_install_browser_menu() {
  case $(menu "Install" "  Chrome\n  Edge\n  Brave\n  Brave Origin\n  Firefox\n󰖟  Zen") in
    *Chrome*) present_terminal "omarchy-install-browser chrome" ;;
    *Edge*) present_terminal "omarchy-install-browser edge" ;;
    *"Brave Origin"*) present_terminal "omarchy-install-browser brave-origin" ;;
    *Brave*) present_terminal "omarchy-install-browser brave" ;;
    *Firefox*) present_terminal "omarchy-install-browser firefox" ;;
    *Zen*) present_terminal "omarchy-install-browser zen" ;;
    *) show_install_menu ;;
  esac
}

show_install_service_menu() {
  case $(menu "Install" "  Dropbox\n  Tailscale\n󱇱  NordVPN [AUR]\n󰏖  ONCE\n󰟵  Bitwarden\n  Chromium Account") in
    *Dropbox*) present_terminal omarchy-install-dropbox ;;
    *Tailscale*) present_terminal omarchy-install-tailscale ;;
    *NordVPN*) present_terminal omarchy-install-nordvpn ;;
    *ONCE*) present_terminal omarchy-install-once ;;
    *Bitwarden*) install_and_launch "Bitwarden" "bitwarden bitwarden-cli" "bitwarden" ;;
    *Chromium*) present_terminal omarchy-install-chromium-google-account ;;
    *) show_install_menu ;;
  esac
}

show_install_editor_menu() {
  case $(menu "Install" "  VSCode\n  Cursor\n  Zed\n  Sublime Text\n  Helix\n  Vim\n  Emacs") in
    *VSCode*) present_terminal omarchy-install-vscode ;;
    *Cursor*) install_and_launch "Cursor" "cursor-bin" "cursor" ;;
    *Zed*) present_terminal omarchy-install-zed ;;
    *Sublime*) install_and_launch "Sublime Text" "sublime-text-4" "sublime_text" ;;
    *Helix*) present_terminal omarchy-install-helix ;;
    *Vim*) install "Vim" "vim" ;;
    *Emacs*) install "Emacs" "emacs-wayland" && systemctl --user enable --now emacs.service ;;
    *) show_install_menu ;;
  esac
}

show_install_terminal_menu() {
  case $(menu "Install" "  Alacritty\n  Foot\n  Ghostty\n  Kitty") in
    *Alacritty*) install_terminal "alacritty" ;;
    *Foot*) install_terminal "foot" ;;
    *Ghostty*) install_terminal "ghostty" ;;
    *Kitty*) install_terminal "kitty" ;;
    *) show_install_menu ;;
  esac
}

show_install_ai_menu() {
  ollama_pkg=$(
    (omarchy-cmd-present nvidia-smi && echo ollama-cuda) ||
      (omarchy-cmd-present rocminfo && echo ollama-rocm) ||
      echo ollama
  )

  case $(menu "Install" "  Dictation\n󱚤  LM Studio\n󱚤  Ollama\n󱚤  Crush") in
    *Dictation*) present_terminal omarchy-voxtype-install ;;
    *Studio*) install "LM Studio" "lmstudio-bin" ;;
    *Ollama*) install "Ollama" "$ollama_pkg" ;;
    *Crush*) install "Crush" "crush-bin" ;;
    *) show_install_menu ;;
  esac
}

show_install_gaming_menu() {
  case $(menu "Install" "  Steam\n  RetroArch\n󰍳  Minecraft\n󰢹  NVIDIA GeForce NOW\n  Xbox Cloud Gaming\n󰂯  Xbox Controller\n󰍹  Moonlight (GameStream)\n  Lutris (Battle.net)\n󱓟  Heroic (Epic Games)") in
    *Steam*) present_terminal omarchy-install-gaming-steam ;;
    *RetroArch*) present_terminal omarchy-install-gaming-retroarch ;;
    *Minecraft*) install_and_launch "Minecraft" "minecraft-launcher" "minecraft-launcher" ;;
    *GeForce*) present_terminal omarchy-install-gaming-geforce-now ;;
    *"Xbox Cloud"*) present_terminal omarchy-install-gaming-xbox-cloud ;;
    *Xbox*) present_terminal omarchy-install-gaming-xbox-controllers ;;
    *Lutris*) present_terminal omarchy-install-gaming-lutris ;;
    *Heroic*) present_terminal omarchy-install-gaming-heroic ;;
    *Moonlight*) present_terminal omarchy-install-gaming-moonlight ;;
    *) show_install_menu ;;
  esac
}

show_install_style_menu() {
  case $(menu "Install" "󰸌  Theme\n  Background\n  Font") in
    *Theme*) present_terminal omarchy-theme-install ;;
    *Background*) omarchy-theme-bg-install ;;
    *Font*) show_install_font_menu ;;
    *) show_install_menu ;;
  esac
}

show_install_font_menu() {
  case $(menu "Install" "  Cascadia Mono\n  Meslo LG Mono\n  Fira Code\n  Victor Code\n  Bitstream Vera Mono\n  Iosevka" "--width 350") in
    *Cascadia*) install_font "Cascadia Mono" "ttf-cascadia-mono-nerd" "CaskaydiaMono Nerd Font" ;;
    *Meslo*) install_font "Meslo LG Mono" "ttf-meslo-nerd" "MesloLGL Nerd Font" ;;
    *Fira*) install_font "Fira Code" "ttf-firacode-nerd" "FiraCode Nerd Font" ;;
    *Victor*) install_font "Victor Code" "ttf-victor-mono-nerd" "VictorMono Nerd Font" ;;
    *Bitstream*) install_font "Bitstream Vera Code" "ttf-bitstream-vera-mono-nerd" "BitstromWera Nerd Font" ;;
    *Iosevka*) install_font "Iosevka" "ttf-iosevka-nerd" "Iosevka Nerd Font Mono" ;;
    *) show_install_menu ;;
  esac
}

show_install_development_menu() {
  case $(menu "Install" "󰫏  Ruby on Rails\n  Docker DB\n  JavaScript\n  Go\n  PHP\n  Python\n  Elixir\n  Zig\n  Rust\n  Java\n  .NET\n  OCaml\n  Clojure\n  Scala") in
    *Rails*) present_terminal "omarchy-install-dev-env ruby" ;;
    *Docker*) present_terminal omarchy-install-docker-dbs ;;
    *JavaScript*) show_install_javascript_menu ;;
    *Go*) present_terminal "omarchy-install-dev-env go" ;;
    *PHP*) show_install_php_menu ;;
    *Python*) present_terminal "omarchy-install-dev-env python" ;;
    *Elixir*) show_install_elixir_menu ;;
    *Zig*) present_terminal "omarchy-install-dev-env zig" ;;
    *Rust*) present_terminal "omarchy-install-dev-env rust" ;;
    *Java*) present_terminal "omarchy-install-dev-env java" ;;
    *NET*) present_terminal "omarchy-install-dev-env dotnet" ;;
    *OCaml*) present_terminal "omarchy-install-dev-env ocaml" ;;
    *Clojure*) present_terminal "omarchy-install-dev-env clojure" ;;
    *Scala*) present_terminal "omarchy-install-dev-env scala" ;;
    *) show_install_menu ;;
  esac
}

show_install_javascript_menu() {
  case $(menu "Install" "  Node.js\n  Bun\n  Deno") in
    *Node*) present_terminal "omarchy-install-dev-env node" ;;
    *Bun*) present_terminal "omarchy-install-dev-env bun" ;;
    *Deno*) present_terminal "omarchy-install-dev-env deno" ;;
    *) show_install_development_menu ;;
  esac
}

show_install_php_menu() {
  case $(menu "Install" "  PHP\n  Laravel\n  Symfony") in
    *PHP*) present_terminal "omarchy-install-dev-env php" ;;
    *Laravel*) present_terminal "omarchy-install-dev-env laravel" ;;
    *Symfony*) present_terminal "omarchy-install-dev-env symfony" ;;
    *) show_install_development_menu ;;
  esac
}

show_install_elixir_menu() {
  case $(menu "Install" "  Elixir\n  Phoenix") in
    *Elixir*) present_terminal "omarchy-install-dev-env elixir" ;;
    *Phoenix*) present_terminal "omarchy-install-dev-env phoenix" ;;
    *) show_install_development_menu ;;
  esac
}
