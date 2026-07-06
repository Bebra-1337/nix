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

    # Список ваших установленных Flatpak приложений
    packages = [
      "com.github.tchx84.Flatseal"
      "io.github.Soundux"
      "io.github.flattool.Warehouse"
      "org.vinegarhq.Sober"
    ];

    # Ваши текущие оверриды прав доступа (глобальные и для Sober)
    overrides = {
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
          filesystems = [
            "xdg-run/app/com.discordapp.Discord:create"
            "xdg-run/discord-ipc-0"
          ];
        };
        Environment = {
          SDL_CAMERA_DRIVER = "pipewire";
        };
      };
    };
  };
}
