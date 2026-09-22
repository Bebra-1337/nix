{ ... }:

{
  # Открываем порты под конфиг VPN (контроллер 9097 + прокси порты) и доверяем TUN-интерфейсу
  networking.firewall = {
    trustedInterfaces = [
      "mihomo"
      "Mihomo"
    ];
    allowedTCPPorts = [
      9097
      7899
      7898
      7897
      7895
      7896
    ];
    allowedUDPPorts = [
      9097
      7899
      7898
      7897
      7895
      7896
    ];
  };

  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
    autoStart = true;
  };
}
