{ ... }:

{
  networking = {
    hostName = "BEBRA-PC";
    # Оставляем IPv6 включенным глобально для loopback (::1), чтобы google3 бинарники не падали с SIGABRT
    enableIPv6 = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    firewall = {
      enable = true;
      # Фиксим reverse path filtering для TUN (нужно VPN-интерфейсу из vpn.nix)
      checkReversePath = "loose";
      trustedInterfaces = [
        "enp6s0"
      ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 0;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.enp6s0.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 0;
  };

  # --- DNS (GeoHide DoH) ---
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNS = [ "https://eu.geohide.ru/dns-query#eu.geohide.ru" ];
        Domains = [ "~." ];
        IPv6 = false;
      };
    };
  };
}
