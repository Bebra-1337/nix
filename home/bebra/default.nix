{ pkgs, ... }:

{
  imports = [
    ./cli/zsh.nix
    ./cli/git.nix
    ./cli/fastfetch.nix
    ./desktop/hyprland.nix
    ./desktop/kitty.nix
    ./desktop/noctalia.nix
    ./theme/gtk.nix
    ./theme/qt.nix
    ./apps.nix
    ./services/polkit.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.11";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERMINAL = "kitty";
    BROWSER = "vivaldi";
    # qt6ct используется для теминга Qt-приложений
    QT_QPA_PLATFORMTHEME = pkgs.lib.mkForce "qt6ct";
    # Заставляет Java/Swing приложения (включая CLion и другие IDE JetBrains) использовать XToolkit (XWayland),
    # что убирает некорректно отрисовываемые GNOME-заголовки окон в Hyprland
    _JAVA_OPTIONS = "-Dawt.toolkit.name=XToolkit";
    # Electron/Chromium-приложения на Nvidia Wayland (перенесены сюда из nvidia.nix)
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # --- EasyEffects ---
  services.easyeffects.enable = true;
  systemd.user.services.easyeffects.Service.ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
}
