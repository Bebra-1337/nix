{ ... }:

{
  services.flatpak = {
    enable = true;

    # Подключаем Flathub
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Список установленных Flatpak приложений (системно)
    packages = [
      # --- Приложения ---
      "com.github.tchx84.Flatseal"
      "io.github.Soundux"
      "io.github.flattool.Warehouse"
      "org.vinegarhq.Sober"
      "org.vinegarhq.Vinegar"
    ];

    # Глобальные и индивидуальные права/переменные приложений
    overrides.settings = {
      global = {
        Context = {
          filesystems = [
            "xdg-config/gtk-4.0:ro"
            "/run/current-system/sw/share/icons:ro"
            "~/.icons:ro"
            "~/.local/share/icons:ro"
            "xdg-config/gtk-3.0:ro"
            "/home/bebra/.themes:ro"
            "/run/current-system/sw/share/themes:ro"
            "~/.local/share/themes:ro"
            "/nix/store:ro"
            "~/.themes:ro"
          ];
        };
        Environment = {
          GTK_THEME = "adw-gtk3";
          ICON_THEME = "yet-another-monochrome-icon-set";
        };
      };

      "org.vinegarhq.Sober" = {
        Context = {
          devices = [ "all" ];
          sockets = [ "wayland" "fallback-x11" "pulseaudio" "gamemode" ];
          filesystems = [
            "xdg-run/app/com.discordapp.Discord:create"
            "xdg-run/discord-ipc-0"
            "/run/udev:ro"
          ];
        };
        Environment = {
          # Оптимизация под Xeon E5-2680 v4 (слабый однопоток) + RTX 4070
          __GL_THREADED_OPTIMIZATIONS = "1"; # Разгрузка главного потока процессора через драйвер NVIDIA
          __GL_SHADER_DISK_CACHE = "1"; # Дисковый кэш шейдеров для убирания микрофризов
          __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
        };
      };

      "com.github.tchx84.Flatseal" = {
        Context = {
          filesystems = [ "/var/lib/flatpak/overrides:ro" ];
        };
      };

      "io.github.Soundux" = {
        Context = {
          # Переключаем на Wayland — без X11 libwnck не инициализируется и не крашится
          sockets = [ "wayland" "!x11" ];
          filesystems = [ "xdg-run/wayland-1" ];
        };
        Environment = {
          GDK_BACKEND = "wayland";
          WAYLAND_DISPLAY = "wayland-1";
          # Adwaita содержит PNG-иконки внутри контейнера — не требует glycin-svg
          ICON_THEME = "Adwaita";
        };
      };
    };

    update.onActivation = true;
  };
}
