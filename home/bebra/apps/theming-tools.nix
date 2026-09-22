{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    papirus-icon-theme
    kdePackages.breeze-icons
  ];
}
