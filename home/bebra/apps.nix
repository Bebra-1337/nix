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
    antigravity-cli
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

    # --- Music ---
    bettersoundcloud

    # --- Utilities ---
    mpv
    imv                   # image viewer (Wayland native)
    obs-studio
    telegram-desktop

    # --- Theme engines & GUI Tools ---
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
  ];

  # Default applications
  # NOTE: vivaldi installs as "vivaldi-stable.desktop", not "vivaldi.desktop"
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File manager
      "inode/directory"            = [ "thunar.desktop" ];

      # Browser — all relevant URL/HTML types
      "text/html"                  = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/http"      = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/https"     = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/ftp"       = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/chrome"    = [ "vivaldi-stable.desktop" ];
      "application/x-extension-htm"  = [ "vivaldi-stable.desktop" ];
      "application/x-extension-html" = [ "vivaldi-stable.desktop" ];
      "application/xhtml+xml"        = [ "vivaldi-stable.desktop" ];
      "application/x-extension-xhtml" = [ "vivaldi-stable.desktop" ];
      "application/x-extension-xht"   = [ "vivaldi-stable.desktop" ];

      # Video
      "video/mp4"                  = [ "mpv.desktop" ];
      "video/mkv"                  = [ "mpv.desktop" ];
      "video/x-matroska"           = [ "mpv.desktop" ];
      "video/webm"                 = [ "mpv.desktop" ];

      # Images
      "image/jpeg"                 = [ "imv.desktop" ];
      "image/png"                  = [ "imv.desktop" ];
      "image/gif"                  = [ "imv.desktop" ];
      "image/webp"                 = [ "imv.desktop" ];
      "image/svg+xml"              = [ "imv.desktop" ];
    };
  };

  # mimeapps.list управляется Nix — перезаписываем принудительно,
  # чтобы Vivaldi / другие приложения не сбрасывали настройки
  xdg.configFile."mimeapps.list".force = true;
}
