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

    hyprcapture = {
      url = "github:gfhdhytghd/HyprCapture";
      flake = false;
    };

    bettersoundcloud = {
      url = "github:AlirezaKJ/BetterSoundCloud";
    };

    elephant = {
      url = "github:abenz1267/elephant";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, bettersoundcloud, ... }:
  let
    system = "x86_64-linux";

    # Build bettersoundcloud directly using buildNpmPackage from the upstream locked nixpkgs,
    # enabling makeCacheWritable natively to bypass the npm EACCES permission issue,
    # and patching the tray icon to PNG during build.
    bettersoundcloudOverlay = final: prev:
    let
      upstreamPkgs = bettersoundcloud.inputs.nixpkgs.legacyPackages.${system};
    in {
      bettersoundcloud = upstreamPkgs.buildNpmPackage {
        pname   = "bettersoundcloud";
        version = "0.7.1";

        src = bettersoundcloud.outPath;

        npmDepsHash = "sha256-Xj+NpXJloa+xVLVMQ3ScSBDpLCUApddr+jcUU2xLHXU=";

        makeCacheWritable = true;
        dontNpmBuild = true;
        ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

        nativeBuildInputs = with upstreamPkgs; [ electron makeWrapper ]
          ++ upstreamPkgs.lib.optionals upstreamPkgs.stdenv.isLinux [ upstreamPkgs.copyDesktopItems ];

        desktopItems = [
          (upstreamPkgs.makeDesktopItem {
            name        = "bettersoundcloud";
            exec        = "bettersoundcloud";
            icon        = "bettersoundcloud";
            comment     = "A PC client of SoundCloud";
            desktopName = "BetterSoundCloud";
            categories  = [ "AudioVideo" "Audio" ];
          })
        ];

        # Replace tray icon path and remove castlabs Widevine components from main.js
        postPatch = ''
          substituteInPlace main.js \
            --replace-quiet "app/lib/assets/icon.ico" \
                            "app/lib/assets/sc-icon-nobg.png" \
            --replace-quiet "  components," "" \
            --replace-quiet "  .then(() => components.whenReady())" ""
        '';

        postInstall = ''
          makeWrapper ${upstreamPkgs.lib.getExe upstreamPkgs.electron} $out/bin/bettersoundcloud \
            --add-flags $out/lib/node_modules/bettersoundcloud/main.js

          install -Dm644 \
            $out/lib/node_modules/bettersoundcloud/app/lib/assets/sc-icon-nobg.png \
            $out/share/icons/hicolor/512x512/apps/bettersoundcloud.png
        '';

        meta = with upstreamPkgs.lib; {
          description = "A PC client of SoundCloud with improvement made using electronjs";
          homepage    = "https://github.com/AlirezaKJ/BetterSoundCloud";
          license     = licenses.mit;
        };
      };
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
