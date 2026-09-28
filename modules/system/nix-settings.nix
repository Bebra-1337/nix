{ config, pkgs, flakeDir, ... }:

{
  # --- Unfree packages ---
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-9.15.9"
  ];

  nix = {
    settings = {
      extra-sandbox-paths = [ "/var/cache/ccache" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      # @wheel достаточно — bebra уже в группе wheel
      trusted-users = [
        "root"
        "@wheel"
      ];
      # Не даём сборщику мусора удалять build-time зависимости (в т.ч. requireFile
      # блобы ida-pro/davinci-resolve-studio) пока жив сам пакет — иначе после
      # каждого nix flake update/gc их приходится добавлять в nix-store заново.
      keep-outputs = true;
      keep-derivations = true;
      # Дубль с nixConfig в flake.nix намеренный:
      # nixConfig нужен для вычисления flake до установки системы,
      # nix.settings — постоянная конфигурация уже установленной системы.
      extra-substituters = [
        "https://hyprland.cachix.org"
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  # GitHub API rate-limit для nix flake update (60/ч без токена -> 5000/ч с ним).
  # Значение — секрет из sops (modules/system/sops.nix, nix_access_tokens), сама
  # строка "access-tokens = github.com=...", `!include` подставляет её в /etc/nix/nix.conf
  # во время чтения конфига самим nix (а не во время сборки), так что путь в /run/secrets
  # существует к этому моменту независимо от порядка активации.
  nix.extraOptions = ''
    !include ${config.sops.secrets.nix_access_tokens.path}
  '';

  # nh чистит с учётом GC roots (вместо nix.gc), nom — читаемый вывод сборок
  programs.nh = {
    enable = true;
    flake = flakeDir;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
  environment.systemPackages = [ pkgs.nix-output-monitor ];
}
