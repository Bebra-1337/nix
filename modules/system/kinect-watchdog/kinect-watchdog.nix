{ pkgs, ... }:

let
  kinect-watchdog = pkgs.stdenv.mkDerivation {
    name = "kinect-watchdog";
    src = ./src;
    buildInputs = [ pkgs.libusb1 ];
    buildPhase = "gcc -Wall -Wextra -O2 -o kinect-watchdog kinect-watchdog.c -lusb-1.0";
    installPhase = "install -Dm755 kinect-watchdog $out/bin/kinect-watchdog";
  };

  kinect-audio = pkgs.stdenv.mkDerivation {
    name = "kinect-audio-setup";
    src = pkgs.fetchgit {
      url = "git://git.ao2.it/kinect-audio-setup.git";
      rev = "v0.5";
      hash = "sha256-bFwmWh822KvFwP/0Gu097nF5K2uCwCLMB1RtP7k+Zt0=";
    };
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.libusb1 ];
    buildPhase = "make -C kinect_upload_fw kinect_upload_fw";
    installPhase = ''
      install -Dm755 kinect_upload_fw/kinect_upload_fw $out/bin/kinect_upload_fw
      install -Dm644 ${./firmware/kinect_uac_firmware.bin} $out/lib/firmware/UACFirmware
    '';
  };
in
{
  # Define plugdev group
  users.groups.plugdev = { };

  # Add udev rules from freenect package and custom rules
  services.udev.packages = [ pkgs.freenect ];

  services.udev.extraRules = ''
    # Permissions for Kinect devices
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02ae", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02b0", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bf", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02bb", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="045e", ATTR{idProduct}=="02c2", MODE="0666", GROUP="plugdev"

    # Firmware upload rule for Kinect Audio (045e:02ad)
    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ad", RUN+="${kinect-audio}/bin/kinect_upload_fw ${kinect-audio}/lib/firmware/UACFirmware"
  '';

  systemd.services.kinect-watchdog = {
    description = "Kinect V1 Watchdog (tilt + LED control)";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${kinect-watchdog}/bin/kinect-watchdog";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
