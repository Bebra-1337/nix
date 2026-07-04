{ inputs, pkgs, ... }:

# ── Stage 1 Bootstrap ──────────────────────────────────────────
# Goal: get VPN running so stage 2 can pull everything else.
# Contains: Hyprland basics, kitty, zsh, koala-clash.
# No HyDE fonts (requires internet).
#
# Usage:
#   sudo nixos-rebuild switch --flake .#BEBRA-PC-bootstrap
# Then start VPN, then:
#   sudo nixos-rebuild switch --flake .#BEBRA-PC
# ──────────────────────────────────────────────────────────────

{
  imports = [
    ./desktop/kitty.nix
    ./cli/zsh.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "kitty";
  };

  home.packages = with pkgs; [
    # VPN
    #koala-clash

    # Hyprland ecosystem minimum
    hyprpaper
    hyprpolkitagent
    wl-clipboard
    libnotify

    # Basic fonts so the desktop is usable
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Minimal Hyprland configs
  # xdg.configFile."hypr/hyprland.lua".source = ../../dotfiles/hypr/hyprland.lua;
  # xdg.configFile."hypr/autostart.lua".source = ../../dotfiles/hypr/autostart.lua;
  # xdg.configFile."hypr/keybinds.lua".source = ../../dotfiles/hypr/keybinds.lua;
  # xdg.configFile."hypr/hyprpaper.conf".source = ../../dotfiles/hypr/hyprpaper.conf;
  # xdg.configFile."hypr/hyprlock.conf".source = ../../dotfiles/hypr/hyprlock.conf;
  # xdg.configFile."hypr/hypridle.conf".source = ../../dotfiles/hypr/hypridle.conf;

  services.hyprpaper.enable = true;
  services.hypridle.enable = true;

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service.ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
    Install.WantedBy = [ "graphical-session.target" ];
  };

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
