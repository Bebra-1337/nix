{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rustdesk-flutter
    pince
    freecad-wayland
    davinci-resolve-studio
  ];
}
