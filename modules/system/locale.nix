{ ... }:

{
  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  # Console keyboard layout
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Wayland keyboard handled by Hyprland directly
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };
}
