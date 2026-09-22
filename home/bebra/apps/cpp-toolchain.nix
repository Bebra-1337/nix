{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    clang-tools # clangd, clang-tidy, clang-format
    cmake
    ninja
    pkg-config
    gdb
    lldb
    valgrind
    python3
    nodejs_22
    pnpm
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
  ];
}
