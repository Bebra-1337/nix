{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  # uwsm start пишет в VT1 свой прогресс ("Created unit subdir ...") между greeter'ом и Hyprland.
  # 1 — без stdout (в журнал всё равно уходит), предупреждения и ошибки остаются.
  # Через PAM-окружение, т.к. ~/.config/uwsm/env читается уже после старта.
  environment.sessionVariables.UWSM_SILENT_START = "1";

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
        numlock = true;
      };
      appearance = {
        scheme = "Synced";
        hide_logo = true;
      };
    };
  };
}
