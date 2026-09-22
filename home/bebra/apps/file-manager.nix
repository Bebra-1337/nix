{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # thunar + plugins: installed system-level via programs.thunar
    xfce4-exo # Thunar "open with terminal"
    poppler-utils # PDF thumbnails (poppler lib is in systemPackages, utils are separate)
    f3d # 3D file previewer (step/obj/stl)
    evince # document viewer
    file-roller # archive manager
  ];
}
