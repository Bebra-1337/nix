{ ... }:

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
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
