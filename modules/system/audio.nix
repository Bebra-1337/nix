{ pkgs, ... }:

{
  # PipeWire — modern low-latency audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth audio codecs (AAC, aptX, LDAC, etc.)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.Policy.AutoEnable = true;
  };
  services.pipewire.wireplumber.extraConfig."bluetooth" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq"  = true;
      "bluez5.enable-msbc"    = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" "ldac" "opus" ];
    };
  };

  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    bluez-tools
    pwvucontrol
  ];
}
