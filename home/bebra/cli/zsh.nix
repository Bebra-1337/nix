{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      # --- Navigation ---
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";

      # --- ls / eza ---
      "ls"   = "eza --icons=always --group-directories-first";
      "ll"   = "eza -lh --icons=always --group-directories-first";
      "la"   = "eza -lah --icons=always --group-directories-first";
      "lt"   = "eza --tree --icons=always --level=2";
      "lta"  = "eza --tree --icons=always --level=3 -a";

      # --- cat / bat ---
      "cat"  = "bat --style=plain";
      "catp" = "bat --paging=never";

      # --- Git ---
      "g"    = "git";
      "gs"   = "git status";
      "ga"   = "git add";
      "gc"   = "git commit";
      "gp"   = "git push";
      "gpl"  = "git pull";
      "gd"   = "git diff";
      "gl"   = "git log --oneline --graph --decorate";
      "gco"  = "git checkout";
      "gb"   = "git branch";

      # --- Nix ---
      "nrs"  = "sudo nixos-rebuild switch --flake /home/bebra/nix#BEBRA-PC";
      "nrt"  = "sudo nixos-rebuild test --flake /home/bebra/nix#BEBRA-PC";
      "nrb"  = "sudo nixos-rebuild boot --flake /home/bebra/nix#BEBRA-PC";
      "hms"  = "home-manager switch --flake /home/bebra/nix#bebra";
      "nfu"  = "nix flake update /home/bebra/nix";
      "ngc"  = "sudo nix-collect-garbage --delete-older-than 14d";
      "nsh"  = "nix shell nixpkgs#";

      # --- C/C++/Qt ---
      "cmake-init" = "cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
      "cmake-dbg"  = "cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
      "cbuild"     = "cmake --build build --parallel $(nproc)";
      "cclean"     = "rm -rf build";

      # --- System ---
      "df"   = "df -h";
      "du"   = "du -sh";
      "free" = "free -h";
      "top"  = "btop";
      "ps"   = "procs";
      "grep" = "grep --color=auto";
      "rm"   = "rm -i";
      "cp"   = "cp -i";
      "mv"   = "mv -i";
      "mkdir" = "mkdir -pv";
      "ports" = "ss -tulpn";

      # --- Apps ---
      "e"    = "zed";
      "v"    = "nvim";
    };

    initContent = ''
      # fzf keybindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # zoxide (smarter cd)
      eval "$(zoxide init zsh)"

      # fzf settings
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

      # direnv hook (also handled by programs.direnv, but explicit for clarity)
      # eval "$(direnv hook zsh)" -- done automatically by programs.direnv

      # C/C++ dev env
      export CC=gcc
      export CXX=g++
      export CMAKE_GENERATOR=Ninja

      # Qt/QML dev
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QML2_IMPORT_PATH="$HOME/.local/lib/qml"
    '';
  };

  # --- Starship prompt — native TOML config ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Link the native starship.toml (managed by Matugen to allow dynamic color updates)
  # xdg.configFile."starship.toml".source = ../../dotfiles/starship.toml;

  # --- Tools used in aliases ---
  home.packages = with pkgs; [
    eza
    bat
    fzf
    fd
    zoxide
    ripgrep
    btop
    procs
    git
    jq
    tokei       # code stats
    hyperfine   # benchmarking
  ];
}
