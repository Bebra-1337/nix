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
    ./services/polkit.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.11"; # выровняно с default.nix
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "kitty";
  };

  home.packages = with pkgs; [
    # Hyprland ecosystem minimum
    wl-clipboard
    libnotify

    # Basic fonts so the desktop is usable
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # hyprpolkitagent перенесён в services/polkit.nix

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}

