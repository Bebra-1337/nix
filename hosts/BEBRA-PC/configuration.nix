{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/vpn.nix
    ../../modules/system/hardware.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/audio.nix
    ../../modules/system/desktop-services.nix
    ../../modules/system/desktop-session.nix
    ../../modules/system/desktop-apps.nix
    ../../modules/system/ssh.nix
    ../../modules/system/dev-tools.nix
    ../../modules/system/gaming.nix
    ../../modules/system/locale.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/sops.nix
    ../../modules/system/users.nix
    ../../modules/system/virtualisation.nix
    ../../modules/system/system-packages.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/kinect-watchdog/kinect-watchdog.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  system.stateVersion = "26.11";
}
