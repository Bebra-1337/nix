{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  hyprcapture = pkgs.hyprlandPlugins.mkHyprlandPlugin {
    pluginName = "hyprcapture";
    version = "0.2.3";
    src = inputs.hyprcapture;
    hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.pkg-config
      pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = [
      pkgs.glib
      pkgs.lua5_4
      pkgs.qt6.qtbase
      pkgs.qt6.qtsvg
      pkgs.kdePackages.layer-shell-qt
      pkgs.nlohmann_json
    ];

    postInstall = ''
      mkdir -p $out/bin
      cp hyprcapture-ui $out/bin/
    '';

    meta = {};
  };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    extraLuaFiles = {
      "bebra.lua" = ../../dotfiles/hypr/hyprland.lua;
      "autostart.lua" = ../../dotfiles/hypr/autostart.lua;
      "keybinds.lua" = ../../dotfiles/hypr/keybinds.lua;
      "hyprcapture_path.lua" = pkgs.writeText "hyprcapture_path.lua" ''
        return {
          so = "${hyprcapture}/lib/libhyprcapture.so",
          ui = "${config.home.homeDirectory}/.local/bin/hyprcapture-ui"
        }
      '';
    };
  };

  # UWSM: export home-manager session variables into the compositor environment
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [
    hyprcapture

    # Launchers / UI
    rofi
    libnotify # notify-send CLI
    matugen
    zip

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
    playerctl

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
  xdg.configFile."hypr/hyprlock.conf".source = ../../dotfiles/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ../../dotfiles/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ../../dotfiles/hypr/hyprpaper.conf;

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

  fonts.fontconfig.enable = true;

  home.activation = {
    copyHyprCaptureUI = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.local/bin
      rm -f $HOME/.local/bin/hyprcapture-ui
      cp -f ${hyprcapture}/bin/hyprcapture-ui $HOME/.local/bin/hyprcapture-ui
      chmod +x $HOME/.local/bin/hyprcapture-ui
    '';
  };
}
