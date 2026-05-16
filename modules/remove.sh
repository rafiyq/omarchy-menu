#!/bin/bash
# Removal menus functions

show_remove_menu() {
  case $(menu "Remove" "󰣇  Package\n  Web App\n  TUI\n󰵮  Development\n󰸌  Theme\n  Browser\n  Dictation\n  Gaming\n󰍲  Windows\n󰏓  Preinstalls\n  Security") in
    *Package*) terminal omarchy-pkg-remove ;;
    *Web*) present_terminal omarchy-webapp-remove ;;
    *TUI*) present_terminal omarchy-tui-remove ;;
    *Development*) show_remove_development_menu ;;
    *Theme*) present_terminal omarchy-theme-remove ;;
    *Browser*) show_remove_browser_menu ;;
    *Dictation*) present_terminal omarchy-voxtype-remove ;;
    *Gaming*) show_remove_gaming_menu ;;
    *Windows*) present_terminal "omarchy-windows-vm remove" ;;
    *Preinstalls*) present_terminal omarchy-remove-preinstalls ;;
    *Security*) show_remove_security_menu ;;
    *) back_to show_main_menu ;;
  esac
}

show_remove_security_menu() {
  case $(menu "Remove" "󰈷 Fingerprint\n Fido2") in
    *Fingerprint*) present_terminal omarchy-remove-security-fingerprint ;;
    *Fido2*) present_terminal omarchy-remove-security-fido2 ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_browser_menu() {
  case $(menu "Remove" " Chrome\n Edge\n Brave\n Brave Origin\n Firefox\n Zen") in
    *Chrome*) present_terminal "omarchy-remove-browser chrome" ;;
    *Edge*) present_terminal "omarchy-remove-browser edge" ;;
    *"Brave Origin"*) present_terminal "omarchy-remove-browser brave-origin" ;;
    *Brave*) present_terminal "omarchy-remove-browser brave" ;;
    *Firefox*) present_terminal "omarchy-remove-browser firefox" ;;
    *Zen*) present_terminal "omarchy-remove-browser zen" ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_gaming_menu() {
  case $(menu "Remove" " Steam\n RetroArch\n󰍳 Minecraft\n󰢹 NVIDIA GeForce NOW\n Xbox Cloud Gaming\n󰂯 Xbox Controller (󰂯)\n󰍹 Moonlight (GameStream)\n Lutris (Battle.net)\n󱓟 Heroic (Epic Games)") in
    *Steam*) present_terminal omarchy-remove-gaming-steam ;;
    *RetroArch*) present_terminal omarchy-remove-gaming-retroarch ;;
    *Minecraft*) present_terminal omarchy-remove-gaming-minecraft ;;
    *GeForce*) present_terminal omarchy-remove-gaming-geforce-now ;;
    *"Xbox Cloud"*) present_terminal omarchy-remove-gaming-xbox-cloud ;;
    *Xbox*) present_terminal omarchy-remove-gaming-xbox-controllers ;;
    *Moonlight*) present_terminal omarchy-remove-gaming-moonlight ;;
    *Lutris*) present_terminal omarchy-remove-gaming-lutris ;;
    *Heroic*) present_terminal omarchy-remove-gaming-heroic ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_development_menu() {
  case $(menu "Remove" "󰫏 Ruby on Rails\n JavaScript\n Go\n PHP\n Python\n Elixir\n Zig\n Rust\n Java\n .NET\n OCaml\n Clojure\n Scala") in
    *Rails*) present_terminal "omarchy-remove-dev-env ruby" ;;
    *JavaScript*) show_remove_javascript_menu ;;
    *Go*) present_terminal "omarchy-remove-dev-env go" ;;
    *PHP*) show_remove_php_menu ;;
    *Python*) present_terminal "omarchy-remove-dev-env python" ;;
    *Elixir*) show_remove_elixir_menu ;;
    *Zig*) present_terminal "omarchy-remove-dev-env zig" ;;
    *Rust*) present_terminal "omarchy-remove-dev-env rust" ;;
    *Java*) present_terminal "omarchy-remove-dev-env java" ;;
    *NET*) present_terminal "omarchy-remove-dev-env dotnet" ;;
    *OCaml*) present_terminal "omarchy-remove-dev-env ocaml" ;;
    *Clojure*) present_terminal "omarchy-remove-dev-env clojure" ;;
    *Scala*) present_terminal "omarchy-remove-dev-env scala" ;;
    *) back_to show_remove_menu ;;
  esac
}

show_remove_javascript_menu() {
  case $(menu "Remove" " Node.js\n Bun\n Deno") in
    *Node*) present_terminal "omarchy-remove-dev-env node" ;;
    *Bun*) present_terminal "omarchy-remove-dev-env bun" ;;
    *Deno*) present_terminal "omarchy-remove-dev-env deno" ;;
    *) back_to show_remove_development_menu ;;
  esac
}

show_remove_php_menu() {
  case $(menu "Remove" " PHP\n Laravel\n Symfony") in
    *PHP*) present_terminal "omarchy-remove-dev-env php" ;;
    *Laravel*) present_terminal "omarchy-remove-dev-env laravel" ;;
    *Symfony*) present_terminal "omarchy-remove-dev-env symfony" ;;
    *) back_to show_remove_development_menu ;;
  esac
}

show_remove_elixir_menu() {
  case $(menu "Remove" " Elixir\n Phoenix") in
    *Elixir*) present_terminal "omarchy-remove-dev-env elixir" ;;
    *Phoenix*) present_terminal "omarchy-remove-dev-env phoenix" ;;
    *) back_to show_remove_development_menu ;;
  esac
}

show_remove_security_menu() {
  case $(menu "Remove" "󰈷  Fingerprint\n  Fido2") in
    *Fingerprint*) present_terminal omarchy-remove-security-fingerprint ;;
    *Fido2*) present_terminal omarchy-remove-security-fido2 ;;
    *) show_remove_menu ;;
  esac
}

show_remove_browser_menu() {
  case $(menu "Remove" "  Chrome\n  Edge\n  Brave\n  Brave Origin\n  Firefox\n  Zen") in
    *Chrome*) present_terminal "omarchy-remove-browser chrome" ;;
    *Edge*) present_terminal "omarchy-remove-browser edge" ;;
    *"Brave Origin"*) present_terminal "omarchy-remove-browser brave-origin" ;;
    *Brave*) present_terminal "omarchy-remove-browser brave" ;;
    *Firefox*) present_terminal "omarchy-remove-browser firefox" ;;
    *Zen*) present_terminal "omarchy-remove-browser zen" ;;
    *) show_remove_menu ;;
  esac
}

show_remove_gaming_menu() {
  case $(menu "Remove" "  Steam\n  RetroArch\n󰍳  Minecraft\n󰢹  NVIDIA GeForce NOW\n  Xbox Cloud Gaming\n󰂯  Xbox Controller (󰂯)\n󰍹  Moonlight (GameStream)\n  Lutris (Battle.net)\n󱓟  Heroic (Epic Games)") in
    *Steam*) present_terminal omarchy-remove-gaming-steam ;;
    *RetroArch*) present_terminal omarchy-remove-gaming-retroarch ;;
    *Minecraft*) present_terminal omarchy-remove-gaming-minecraft ;;
    *GeForce*) present_terminal omarchy-remove-gaming-geforce-now ;;
    *"Xbox Cloud"*) present_terminal omarchy-remove-gaming-xbox-cloud ;;
    *Xbox*) present_terminal omarchy-remove-gaming-xbox-controllers ;;
    *Moonlight*) present_terminal omarchy-remove-gaming-moonlight ;;
    *Lutris*) present_terminal omarchy-remove-gaming-lutris ;;
    *Heroic*) present_terminal omarchy-remove-gaming-heroic ;;
    *) show_remove_menu ;;
  esac
}

show_remove_development_menu() {
  case $(menu "Remove" "󰫏  Ruby on Rails\n  JavaScript\n  Go\n  PHP\n  Python\n  Elixir\n  Zig\n  Rust\n  Java\n  .NET\n  OCaml\n  Clojure\n  Scala") in
    *Rails*) present_terminal "omarchy-remove-dev-env ruby" ;;
    *JavaScript*) show_remove_javascript_menu ;;
    *Go*) present_terminal "omarchy-remove-dev-env go" ;;
    *PHP*) show_remove_php_menu ;;
    *Python*) present_terminal "omarchy-remove-dev-env python" ;;
    *Elixir*) show_remove_elixir_menu ;;
    *Zig*) present_terminal "omarchy-remove-dev-env zig" ;;
    *Rust*) present_terminal "omarchy-remove-dev-env rust" ;;
    *Java*) present_terminal "omarchy-remove-dev-env java" ;;
    *NET*) present_terminal "omarchy-remove-dev-env dotnet" ;;
    *OCaml*) present_terminal "omarchy-remove-dev-env ocaml" ;;
    *Clojure*) present_terminal "omarchy-remove-dev-env clojure" ;;
    *Scala*) present_terminal "omarchy-remove-dev-env scala" ;;
    *) show_remove_menu ;;
  esac
}

show_remove_javascript_menu() {
  case $(menu "Remove" "  Node.js\n  Bun\n  Deno") in
    *Node*) present_terminal "omarchy-remove-dev-env node" ;;
    *Bun*) present_terminal "omarchy-remove-dev-env bun" ;;
    *Deno*) present_terminal "omarchy-remove-dev-env deno" ;;
    *) show_remove_development_menu ;;
  esac
}

show_remove_php_menu() {
  case $(menu "Remove" "  PHP\n  Laravel\n  Symfony") in
    *PHP*) present_terminal "omarchy-remove-dev-env php" ;;
    *Laravel*) present_terminal "omarchy-remove-dev-env laravel" ;;
    *Symfony*) present_terminal "omarchy-remove-dev-env symfony" ;;
    *) show_remove_development_menu ;;
  esac
}

show_remove_elixir_menu() {
  case $(menu "Remove" "  Elixir\n  Phoenix") in
    *Elixir*) present_terminal "omarchy-remove-dev-env elixir" ;;
    *Phoenix*) present_terminal "omarchy-remove-dev-env phoenix" ;;
    *) show_remove_development_menu ;;
  esac
}
