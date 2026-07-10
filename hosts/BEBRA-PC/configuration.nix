{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/audio.nix
    ../../modules/system/gaming.nix
    ../../modules/system/locale.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/kinect-watchdog/kinect-watchdog.nix
    inputs.noctalia-greeter.nixosModules.default
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
        theme = ./themes/CyberGRUB-2077;
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
      "mitigations=off"
    ];
    kernelPackages = pkgs.linuxPackages_latest;

    plymouth = {
      enable = true;
      theme = "evangelion-ui";
      themePackages = [
        inputs.evangelion-ui-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
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
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  powerManagement.cpuFreqGovernor = "performance";


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
    blueman.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
  };

  # --- PAM ---
  security.pam.services.hyprlock = { };

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

  # Оверлей для бесшумного запуска UWSM при входе через greeter.
  # Мы перехватываем запуск uwsm и, если он запущен из-под greetd, перенаправляем его вывод в /dev/null.
  # Это сохраняет стандартную сессию без создания кастомных desktop-файлов.
  nixpkgs.overlays = [
    (final: prev: {
      uwsm = prev.symlinkJoin {
        name = "uwsm-silent-wrapper";
        paths = [ prev.uwsm ];
        postBuild = ''
          rm $out/bin/uwsm
          cat << 'EOF' > $out/bin/uwsm
          #!/bin/sh
          if [ -n "$GREETD_SOCK" ] && [ "$1" = "start" ]; then
            exec ${prev.uwsm}/bin/uwsm "$@" >/dev/null 2>&1
          else
            exec ${prev.uwsm}/bin/uwsm "$@"
          fi
          EOF
          chmod +x $out/bin/uwsm
        '';
        meta.mainProgram = "uwsm";
      };
    })
  ];

  # --- Greeter ---
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
        numlock = true;
      };
      appearance = {
        scheme = "Synced";
        hide_logo = true;
      };
    };
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
    ollama
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
