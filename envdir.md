Qt 5.12.3 + Qt Creator через Nix flake
  
  1. Найти коммит nixpkgs с нужной версией Qt
  
  Идёшь на Nix Package Versions
  (https://lazamar.co.uk/nix-versions/?package=qt5&version=5.12.3&fullName=qt5-5.12.3&keyName=qt5&revision=&channel=nixpkgs
  -unstable) — вводишь qt5, версию 5.12.3, получаешь коммит-хэш nixpkgs.
  
  2. flake.nix проекта
  
  {
    inputs = {
      # Пиннишь старый nixpkgs с Qt 5.12.3
      nixpkgs-qt5.url = "github:nixos/nixpkgs/ХЭШ_ИЗ_ШАГА_1";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };
  
    outputs = { nixpkgs, nixpkgs-qt5, ... }:
    let
      system = "x86_64-linux";
      pkgs      = nixpkgs.legacyPackages.${system};
      pkgs-qt5  = nixpkgs-qt5.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs-qt5.qt5.qtbase
          pkgs-qt5.qt5.qtdeclarative   # QML
          pkgs-qt5.qt5.qttools         # qmake, etc
          pkgs-qt5.qt5.wrapQtAppsHook
          pkgs.gcc
          pkgs.cmake
          pkgs.ninja
          pkgs.clang-tools             # clangd
        ];
  
        shellHook = ''
          export QT_SELECT=5
          export CMAKE_EXPORT_COMPILE_COMMANDS=ON
        '';
      };
    };
  }
  
  3. .envrc
  
  echo "use flake" > .envrc
  direnv allow
  
  4. Запуск Qt Creator из проекта
  
  cd ~/projects/my-qt5-app
  # direnv активировал окружение — Qt 5.12.3 в PATH
  qtcreator .
  
  Qt Creator откроется и увидит qmake/cmake из окружения. В настройках Qt Creator (Tools → Kits) он автоматически обнаружит
  Qt из PATH — нужно один раз нажать "Auto-detect".
