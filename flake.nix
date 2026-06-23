{
  description = "BEBRA-PC NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcapture = {
      url = "github:gfhdhytghd/HyprCapture";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    mkSystem = nixosModule: homeModule: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/BEBRA-PC/configuration.nix
        nixosModule
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
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
