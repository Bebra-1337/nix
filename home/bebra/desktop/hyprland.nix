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

    # Clipboard
    cliphist
    wl-clipboard

    grimblast # fallback

    # Audio control (replaces pavucontrol)
    hyprpwcenter
    playerctl

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
  # hyprpolkitagent перенесён в services/polkit.nix

  fonts.fontconfig.enable = true;
}
