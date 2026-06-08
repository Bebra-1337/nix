{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- Browser ---
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    })
    vivaldi-ffmpeg-codecs

    # --- File manager ---
    thunar
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
    tumbler                   # thumbnail generator
    xfce4-exo                 # Thunar "open with terminal"
    ffmpegthumbnailer         # video thumbnails
    poppler-utils         # PDF thumbnails
    libgsf                    # ODF thumbnails
    f3d                       # 3D file previewer (step/obj/stl)
    evince                    # document viewer
    file-roller               # archive manager

    # --- IDE / Editors ---
    zed-editor
    qtcreator

    # --- C/C++/Qt development ---
    gcc
    clang-tools          # clangd, clang-tidy, clang-format
    cmake
    ninja
    pkg-config
    gdb
    lldb
    valgrind
    ccache

    # Qt libs
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qttools
    qt6.qtdoc
    qt6.qtvirtualkeyboard
    qt6.qtwayland
    qt6.qtsvg
    qt6.qtmultimedia

    # Build helpers
    meson
    autoconf
    automake
    libtool

    # --- VPN (installed in bootstrap stage, kept here for completeness) ---
    clash-verge-rev

    # --- Messaging ---
    (discord.override {
      withVencord  = true;
      withOpenASAR = true;   # faster app.asar replacement
    })

    # --- SSH ---
    openssh
    # Extra tools
    gamemode
    gamescope

    # --- Utilities ---
    mpv
    imv                   # image viewer (Wayland native)
    obs-studio
    telegram-desktop
  ];

  # Thunar as default file manager
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "text/html" = [ "vivaldi.desktop" ];
      "x-scheme-handler/http" = [ "vivaldi.desktop" ];
      "x-scheme-handler/https" = [ "vivaldi.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/mkv" = [ "mpv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
    };
  };
}
