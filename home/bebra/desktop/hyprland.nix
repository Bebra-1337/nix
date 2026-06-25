{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  toggle-record = pkgs.writeShellScriptBin "toggle-record" ''
    SAVE_DIR="$HOME/Videos/Recordings"
    mkdir -p "$SAVE_DIR"

    if pgrep -x "gpu-screen-recorder" > /dev/null; then
        pkill -SIGINT -f gpu-screen-recorder
        ${pkgs.libnotify}/bin/notify-send -t 3000 "Запись экрана" "Запись остановлена и сохранена"
    else
        gpu-screen-recorder -w screen -f 60 -a defaultoutput -o "$SAVE_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4" &
        ${pkgs.libnotify}/bin/notify-send -t 3000 "Запись экрана" "Запись экрана запущена"
    fi
  '';

  screenshot-menu = pkgs.writeShellScriptBin "screenshot-menu" ''
    OPTIONS="  Область\n  Окно\n🖥  Экран\n  Запись"
    
    CHOICE=$(echo -e "$OPTIONS" | \
      WALKER_SHELL_ANCHOR_BOTTOM=true \
      WALKER_SHELL_ANCHOR_TOP=false \
      WALKER_SHELL_ANCHOR_LEFT=false \
      WALKER_SHELL_ANCHOR_RIGHT=false \
      walker --dmenu \
             --theme screenshot_menu \
             --width 600 \
             --height 80 \
             --placeholder "Захват экрана" \
             --nosearch \
             --nohints)

    case "$CHOICE" in
      *"Область"*)
        GRIMBLAST_EDITOR="satty --filename" grimblast edit area
        ;;
      *"Окно"*)
        GRIMBLAST_EDITOR="satty --filename" grimblast edit active
        ;;
      *"Экран"*)
        GRIMBLAST_EDITOR="satty --filename" grimblast edit screen
        ;;
      *"Запись"*)
        ${toggle-record}/bin/toggle-record
        ;;
    esac
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    extraLuaFiles = {
      "bebra.lua" = ../../../dotfiles/hypr/hyprland.lua;
      "autostart.lua" = ../../../dotfiles/hypr/autostart.lua;
      "keybinds.lua" = ../../../dotfiles/hypr/keybinds.lua;
    };
  };

  # UWSM: export home-manager session variables into the compositor environment
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  home.packages = with pkgs; [
    screenshot-menu
    toggle-record

    # Launchers / UI
    libnotify # notify-send CLI
    matugen
    zip

    # Polkit (Hypr ecosystem)
    hyprpolkitagent

    # Clipboard
    cliphist
    wl-clipboard

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
  # xdg.configFile."hypr/hyprland.lua".source = ../../../dotfiles/hypr/hyprland.lua;
  # xdg.configFile."hypr/autostart.lua".source = ../../../dotfiles/hypr/autostart.lua;
  # xdg.configFile."hypr/keybinds.lua".source = ../../../dotfiles/hypr/keybinds.lua;
  xdg.configFile."hypr/hyprlock.conf".source = ../../../dotfiles/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ../../../dotfiles/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ../../../dotfiles/hypr/hyprpaper.conf;

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
}
