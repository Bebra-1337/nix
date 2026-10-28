{ ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # podman — сборка .so под Steam Runtime (образ steamrt sniper SDK)
  virtualisation.podman.enable = true;
}
