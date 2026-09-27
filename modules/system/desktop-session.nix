{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

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
