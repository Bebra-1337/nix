{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Extra tools
    satty
    deadlock-mod-manager
    scrcpy
    android-tools
    sshfs
    remmina

    # --- Music ---
    bebrasoundcloud

    # --- Torrents ---
    qbittorrent

    # --- MineCraft ---
    prismlauncher

    # --- Utilities ---
    sops
    age
    ssh-to-age
    mpv
    imv # image viewer (Wayland native)
    obs-studio
    ayugram-desktop
  ];
}
