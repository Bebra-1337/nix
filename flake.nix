{
  description = "BEBRA-PC NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "noctalia.cachix.org-1:QLqKTBuOXLLr0wQlBOy3DkUjgZ1BNLvL/fDp6f+FMYY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprcapture = {
      url = "github:gfhdhytghd/HyprCapture";
      flake = false;
    };

    bettersoundcloud = {
      url = "github:AlirezaKJ/BetterSoundCloud";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, bettersoundcloud, ... }:
  let
    system = "x86_64-linux";

    # Оверлей: патчим BetterSoundCloud — заменяем icon.ico на PNG для Linux-трея
    bettersoundcloudOverlay = final: prev: {
      bettersoundcloud = bettersoundcloud.packages.${system}.default.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace main.js \
            --replace-quiet "app/lib/assets/icon.ico" \
                            "$out/lib/node_modules/bettersoundcloud/app/lib/assets/sc-icon-nobg.png"
        '';
      });
    };

    mkSystem = nixosModule: homeModule: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = [ bettersoundcloudOverlay ]; }
        ./hosts/BEBRA-PC/configuration.nix
        nixosModule
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [
              inputs.hyprland.homeManagerModules.default
            ];
            users.bebra = homeModule;
          };
        }
      ];
    };
  in
  {
    nixosConfigurations = {
      # ── Stage 1: VPN + minimal desktop ──
      # sudo nixos-rebuild switch --flake .#BEBRA-PC-bootstrap
      BEBRA-PC-bootstrap = mkSystem
        ./hosts/BEBRA-PC/bootstrap.nix
        (import ./home/bebra/bootstrap.nix);

      # ── Stage 2: Full config (run after VPN is up) ──
      # sudo nixos-rebuild switch --flake .#BEBRA-PC
      BEBRA-PC = mkSystem
        ({ ... }: { })   # no extra system module needed
        (import ./home/bebra/default.nix);
    };
  };
}
