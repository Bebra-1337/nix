{ pkgs, ... }:

{
  # Замена noctalia (кроме лаунчера — тот уже walker) на отдельные тулы.
  # Только пакеты — конфиги живут обычными файлами в дефолтных местах
  # (~/.config/hypr/{hyprlock,hypridle,hyprpaper}.conf, ~/.config/swaync/,
  # ~/.config/waybar/), автозапуск — в ~/.config/hypr/autostart.lua.
  home.packages = with pkgs; [
    waybar # топбар (ironbar не умеет прятать лишние иконки трея за шевроном, waybar — умеет через group+drawer)
    hyprlock # лок-скрин
    hypridle # idle-демон (авто-lock/dpms)
    swaybg # обои (hyprpaper 0.8.4 падает на этой NVIDIA-системе — новый рендер-тулкит требует EGL device enumeration, а eglQueryDevicesEXT тут падает с EGL_BAD_ALLOC)
    swaynotificationcenter # уведомления + центр уведомлений
    swayosd # OSD громкости/яркости
  ];
}
