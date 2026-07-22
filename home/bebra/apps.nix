{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # --- Browser ---
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    })
    vivaldi-ffmpeg-codecs

    # --- File manager ---
    # thunar + plugins: installed system-level via programs.thunar
    xfce4-exo # Thunar "open with terminal"
    poppler-utils # PDF thumbnails (poppler lib is in systemPackages, utils are separate)
    f3d # 3D file previewer (step/obj/stl)
    evince # document viewer
    file-roller # archive manager

    # --- IDE / Editors ---
    zed-editor
    qtcreator
    antigravity-cli
    inputs.llm-agents.packages.${pkgs.system}.mimo-code
    jetbrains.clion
    onlyoffice-desktopeditors
    libreoffice-qt
    # --- C/C++/Qt development ---
    gcc
    clang-tools # clangd, clang-tidy, clang-format
    cmake
    ninja
    pkg-config
    gdb
    lldb
    valgrind
    python3
    # ccache не нужен здесь: programs.ccache.enable уже делает его доступным системно
    nil
    nixd
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

    # --- Messaging ---
    (discord.override {
      withVencord = true;
      withOpenASAR = false; # faster app.asar replacement
    })

    # --- Work ---
    rustdesk-flutter
    ghidra
    ida-free
    freecad-wayland
    davinci-resolve-studio

    # Extra tools
    satty

    # --- Music ---
    bebrasoundcloud

    # --- MineCraft ---
    prismlauncher

    # --- Utilities ---
    mpv
    imv # image viewer (Wayland native)
    obs-studio
    ayugram-desktop
    kdePackages.kdeconnect-kde

    # --- Theme engines & GUI Tools ---
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    papirus-icon-theme
    kdePackages.breeze-icons
  ];
}
