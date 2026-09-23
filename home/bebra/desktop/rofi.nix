{ pkgs, ... }:

{
  # Апплаунчер с плиточной сеткой — заменяет walker для SUPER+A (walker
  # остаётся для буфера обмена/emoji, см. keybinds.lua). Пакет only:
  # тема живёт в ~/.config/rofi/config.rasi (дефолтное место, не nix).
  home.packages = with pkgs; [
    rofi # с 2025 нативно поддерживает Wayland (rofi-wayland влился обратно)
  ];
}
