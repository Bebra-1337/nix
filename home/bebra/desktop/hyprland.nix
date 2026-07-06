{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
  };

  # UWSM: export home-manager session variables into the compositor environment
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [

    # Launchers / UI
    libnotify # notify-send CLI
    zip

    # Polkit (Hypr ecosystem)
    hyprpolkitagent

    # Clipboard
    cliphist
    wl-clipboard

    grimblast # fallback

    # Audio control (replaces pavucontrol)
    hyprpwcenter
    playerctl

    # Idle / lock
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
  xdg.configFile."hypr/hyprland.lua" = {
    source = ../../../dotfiles/hypr/hyprland.lua;
    force = true;
  };
  xdg.configFile."hypr/autostart.lua" = {
    source = ../../../dotfiles/hypr/autostart.lua;
    force = true;
  };
  xdg.configFile."hypr/keybinds.lua" = {
    source = ../../../dotfiles/hypr/keybinds.lua;
    force = true;
  };
  xdg.configFile."hypr/hyprlock.conf" = {
    source = ../../../dotfiles/hypr/hyprlock.conf;
    force = true;
  };
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

  fonts.fontconfig.enable = true;
}
