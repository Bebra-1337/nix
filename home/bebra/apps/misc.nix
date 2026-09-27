{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Extra tools
    satty
    deadlock-mod-manager
    remmina

    # --- Phone (KDE Connect + noctalia phone-operate) ---
    scrcpy
    android-tools
    sshfs
    glib # gdbus — плагин опрашивает KDE Connect по D-Bus
    zenity # диалог выбора файла в плагине

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
    celluloid # GTK4-плеер на базе mpv
    loupe # image viewer (GTK4)
    obs-studio
    ayugram-desktop
  ];
}
