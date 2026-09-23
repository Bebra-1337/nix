{ pkgs, ... }:

{
  # Апплаунчер с плиточной сеткой (SUPER+A) + компаньоны того же rofi-семейства.
  # Пакеты only — темы живут обычными файлами в дефолтных местах, не в nix:
  #   ~/.config/rofi/config.rasi        — тема лаунчера/буфера/эмодзи
  #   ~/.config/wlogout/{layout,style.css} — меню логаута/питания
  home.packages = with pkgs; [
    rofi # с 2025 нативно поддерживает Wayland (rofi-wayland влился обратно)
    rofimoji # эмодзи/символы через rofi (заменяет walker -m symbols)
    wlogout # плиточное меню логаута/питания (заменяет walker --dmenu меню)
  ];
}
