{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/audio.nix
    ../../modules/system/gaming.nix
    ../../modules/system/locale.nix
    ../../modules/system/kinect-watchdog/kinect-watchdog.nix
  ];

  # --- Boot ---
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
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # --- Networking ---
  networking = {
    hostName = "BEBRA-PC";
    networkmanager.enable = true;
    # Открываем порты под твой конфиг (контроллер 9097 + прокси порты) + фиксим reverse path filtering для TUN
    firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [
        "mihomo"
        "Mihomo"
        "enp6s0"
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
  };

  # --- Hardware ---
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # --- Unfree packages ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-9.15.9"
  ];

  # --- SSH ---
  programs.ssh.startAgent = true;

  # --- Services ---
  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
    openssh = {
      enable = true;
    };
    upower.enable = true;
    power-profiles-daemon.enable = true;
    xserver.enable = true;
    flatpak.enable = true;
    displayManager.ly.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
  };

  # --- PAM ---
  security.pam.services.hyprlock = { };

  # Даём mihomo права на TUN/raw sockets, чтобы Koala Clash мог поднимать TUN от пользователя
  # security.wrappers.mihomo = {
  #   owner = "root";
  #   group = "root";
  #   capabilities = "cap_net_bind_service,cap_net_admin,cap_net_raw+ep";
  #   source = "${pkgs.mihomo}/bin/mihomo";
  # };

  # --- ccache ---
  programs.ccache.enable = true;

  # --- Hyprland ---
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  # --- Users ---
  users.users.bebra = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "plugdev"
      "libvirtd"
    ];
  };

  # --- Programs ---
  programs = {
    clash-verge = {
      enable = true;
      tunMode = true;
      serviceMode = true;
      autoStart = true;
    };
    kdeconnect.enable = true;
    nix-ld.enable = true;
    zsh.enable = true;
    dconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
  };

  # --- Portals ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # --- Virtualisation ---
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # --- Flatpak: Flathub + latest runtimes + Nvidia extensions ---
  systemd.services.flatpak-setup = {
    description = "Setup Flatpak remotes and runtimes";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.flatpak
      pkgs.gnugrep
      pkgs.coreutils
    ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # Install latest available branch of a runtime
      install_latest() {
        local ref="$1"
        local branch
        branch=$(flatpak remote-ls --columns=ref flathub 2>/dev/null \
          | grep "^$ref//" | grep -oP '(?<=//)[\d.]+$' | sort -V | tail -1)
        [ -n "$branch" ] && flatpak install -y --noninteractive flathub "$ref//$branch" || true
      }

      install_latest org.freedesktop.Platform
      install_latest org.freedesktop.Sdk
      install_latest org.gnome.Platform
      install_latest org.gnome.Sdk
      install_latest org.kde.Platform
      install_latest org.kde.Sdk

      # Nvidia extensions — Flatpak auto-selects version matching host driver
      flatpak install -y --noninteractive flathub org.freedesktop.Platform.GL.nvidia-open || true
      flatpak install -y --noninteractive flathub org.freedesktop.Platform.VAAPI.nvidia   || true
    '';
  };

  # --- System packages ---
  # gvfs и tumbler устанавливаются автоматически через services.*.enable
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    file
    ffmpegthumbnailer
    poppler
    libgsf
    #koala-clash
    ollama
    fastfetch
  ];

  # --- Nix settings ---
  nix = {
    settings = {
      extra-sandbox-paths = [ "/var/cache/ccache" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "bebra"
      ];
      extra-substituters = [
        "https://hyprland.cachix.org"
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "26.11";
}
