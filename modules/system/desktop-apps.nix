{ pkgs, ... }:

{
  programs.kdeconnect.enable = true;
  programs.ydotool.enable = true;
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  # setcap-обёртка для gsr-kms-server: запись экрана без запроса пароля (noctalia screen-toolkit, snip)
  programs.gpu-screen-recorder.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
