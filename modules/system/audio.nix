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

  # Realtime priority for audio apps that set it directly (sfizz in SoundCraft)
  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  environment.systemPackages = with pkgs; [
    pwvucontrol
  ];
}
