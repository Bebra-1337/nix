{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1; # prefer maximum performance
      };
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    lutris
    heroic
    wine-staging
    winetricks
    vulkan-tools
    vulkan-loader
  ];
}
