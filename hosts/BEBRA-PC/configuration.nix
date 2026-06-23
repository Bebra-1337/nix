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
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "quiet"
      "splash"
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # --- Networking ---
  networking = {
    hostName = "BEBRA-PC";
    networkmanager.enable = true;
  };

  # --- Hardware ---
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # --- Unfree packages ---
  nixpkgs.config.allowUnfree = true;

  # --- SSH ---
  programs.ssh.startAgent = true;
  services.openssh.enable = true;

  # --- Services ---
  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
    xserver.enable = true;
    flatpak.enable = true;
    displayManager.ly.enable = true;
  };

  # --- PAM ---
  security.pam.services.hyprlock = { };

  # --- ccache ---
  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];

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
    ];
  };

  # --- Programs ---
  programs = {
    zsh.enable = true;
    dconf.enable = true;
    clash-verge = {
      enable = true;
      tunMode = true;
      autoStart = true;
      serviceMode = true;
    };
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
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    file
    gvfs
    tumbler
    ffmpegthumbnailer
    poppler
    libgsf
  ];

  # --- Nix settings ---
  nix = {
    settings = {
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
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
