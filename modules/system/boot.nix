{ inputs, pkgs, ... }:

{
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        splashImage = null;
        theme = ../../hosts/BEBRA-PC/themes/CyberGRUB-2077;
      };
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "systemd.show_status=false"
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      # "mitigations=off" # удалено: уязвимость к Spectre/Meltdown без ощутимого прироста на десктопе
    ];
    kernelPackages = pkgs.linuxPackages_latest;

    plymouth = {
      enable = true;
      theme = "evangelion-ui";
      themePackages = [
        inputs.evangelion-ui-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
