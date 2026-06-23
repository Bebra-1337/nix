{ inputs, pkgs, ... }:

let
  yet-another-monochrome-icon-set = pkgs.stdenv.mkDerivation {
    name = "yet-another-monochrome-icon-set";
    src = pkgs.fetchgit {
      url = "https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git";
      rev = "40baf4612a8a73ed0f5a75cdf073db476aa3ca99";
      hash = "sha256-bBCwWzPf7k7a3RwP4L90xeTwk+YkKrS9sxRb9KLnBL4=";
    };
    installPhase = ''
      mkdir -p $out/share/icons
      cp -r . $out/share/icons/yet-another-monochrome-icon-set
    '';
  };
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    ./hyprland.nix
    ./kitty.nix
    ./zsh.nix
    ./apps.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.11";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # --- Dank Material Shell (DMS) ---
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
    settings = {
      theme = "dark";
      dynamicTheming = true;
    };
  };

  # --- Git ---
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Romanov Bebra";
      user.email = "bebra@bebralegendick.ru";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.editor = "zed --wait";
    };
  };

  # --- direnv + nix-direnv ---
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # --- nix-index (nix-locate to find packages by file) ---
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- Session variables ---
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERMINAL = "kitty";
    BROWSER = "vivaldi";
  };

  # --- GTK theming ---
  gtk = {
    enable = true;
    iconTheme = {
      package = yet-another-monochrome-icon-set;
      name = "yet-another-monochrome-icon-set";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # --- XDG dirs ---
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
