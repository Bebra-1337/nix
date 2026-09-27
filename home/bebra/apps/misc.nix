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
    soundcloud-rpc

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
