{ pkgs, config, ... }:

{
  imports = [
    ./aliases.nix
    ./init.nix
    ./starship.nix
    ./fzf.nix
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    dotDir = "${config.xdg.configHome}/zsh"; # абсолютный путь (относительные deprecated в HM)
    autocd = true;
    enableCompletion = true;

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
    ];

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
  };

  # --- Tools used in aliases ---
  home.packages = with pkgs; [
    eza
    bat
    fd
    zoxide
    ripgrep
    btop
    procs
    jq
    tokei # code stats
    hyperfine # benchmarking
  ];
}
