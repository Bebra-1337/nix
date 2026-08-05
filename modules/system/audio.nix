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

  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pwvucontrol
  ];
}
