{
  description = "BEBRA-PC NixOS configuration";

  # nixConfig нужен для вычисления flake до установки системы (первый запуск).
  # Те же значения есть в nix.settings в configuration.nix — для постоянной конфигурации системы.
  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
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

    # ── hyprcapture удален отсюда ──

    bebrasoundcloud = {
      url = "git+file:///home/bebra/soundcloud-rpc";
      # TODO: перенести на github-репо для воспроизводимости
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    millennium = {
      url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    evangelion-ui-plymouth = {
      url = "gitlab:lobstermane/evangelion-ui-plymouth";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      bebrasoundcloudOverlay = import ./overlays/bebrasoundcloud.nix { inherit inputs system; };
      mihomoOverlay = import ./overlays/mihomo.nix;
      antigravity-cliOverlay = import ./overlays/antigravity-cli.nix;
      millenniumOverlay = inputs.millennium.overlays.default;
      davinciResolveOverlay = import ./overlays/davinci-resolve.nix;

      mkSystem =
        nixosModule: homeModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs.overlays = [
                bebrasoundcloudOverlay
                mihomoOverlay
                antigravity-cliOverlay
                millenniumOverlay
                davinciResolveOverlay
              ];
            }
            ./hosts/BEBRA-PC/configuration.nix
            nixosModule
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
                sharedModules = [
                  inputs.hyprland.homeManagerModules.default
                  inputs.noctalia.homeModules.default
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
        BEBRA-PC-bootstrap = mkSystem ({ ... }: { }) (import ./home/bebra/bootstrap.nix);

        # ── Stage 2: Full config (run after VPN is up) ──
        # sudo nixos-rebuild switch --flake .#BEBRA-PC
        BEBRA-PC =
          mkSystem ({ ... }: { }) # no extra system module needed
            (import ./home/bebra/default.nix);
      };
    };
}
