{
  inputs,
  pkgs,
  config,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    extraLuaFiles = { "bebra.lua" = ../../dotfiles/hypr/hyprland.lua; };
  };

  # UWSM: export home-manager session variables into the compositor environment
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [
    # Launchers / UI
    rofi
    libnotify # notify-send CLI

    # Polkit (Hypr ecosystem)
    hyprpolkitagent

    # Clipboard
    cliphist
    wl-clipboard

    # Screenshot: после входа запустить:
    # hyprpm update && hyprpm add https://github.com/gfhdhytghd/HyprCapture && hyprpm enable hyprcapture
    grimblast # fallback

    # Wallpaper
    hyprpaper

    # Audio control (replaces pavucontrol)
    hyprpwcenter

    # Idle / lock
    hypridle
    hyprlock

    # Screen color temperature
    hyprsunset

    # Wayland tools
    wlr-randr
    wl-mirror
    xev

    # Fonts — nixpkgs
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Fonts — HyDE (все есть в nixpkgs)
    nerd-fonts.caskaydia-cove
    maple-mono.NF
    material-design-icons
    nerd-fonts.mononoki
  ];

  # Link the native Lua configs (Hyprland >= 0.55)
  # xdg.configFile."hypr/hyprland.lua".source = ../../dotfiles/hypr/hyprland.lua;
  # xdg.configFile."hypr/autostart.lua".source = ../../dotfiles/hypr/autostart.lua;
  # xdg.configFile."hypr/keybinds.lua".source = ../../dotfiles/hypr/keybinds.lua;
  # xdg.configFile."hypr/hyprlock.conf".source = ../../dotfiles/hypr/hyprlock.conf;
  # xdg.configFile."hypr/hypridle.conf".source = ../../dotfiles/hypr/hypridle.conf;
  # xdg.configFile."hypr/hyprpaper.conf".source = ../../dotfiles/hypr/hyprpaper.conf;

  # systemd user services under UWSM
  services.hypridle.enable = true;
  services.hyprpaper.enable = true;

  # hyprpolkitagent as systemd user service
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # noctalia-shell as systemd user service
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "noctalia-shell";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  fonts.fontconfig.enable = true;
}
