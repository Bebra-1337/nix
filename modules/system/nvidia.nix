{ config, pkgs, ... }:

{
  # RTX 4070 — open-source kernel modules (supported on Ada Lovelace+)
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;            # nvidia-open for RTX 40xx
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      finegrained = false;  # only for hybrid/optimus setups
    };
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  # Системные переменные GPU-уровня
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    # NIXOS_OZONE_WL и ELECTRON_OZONE_PLATFORM_HINT перенесены в home.sessionVariables
    # (это переменные уровня пользовательской сессии, а не системные)
  };
}
