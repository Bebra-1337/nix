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
    ./hyprland.nix
    ./kitty.nix
    ./zsh.nix
    ./apps.nix
    ./matugen.nix
  ];

  home = {
    username = "bebra";
    homeDirectory = "/home/bebra";
    stateVersion = "26.11";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

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
    # qt6ct используется Noctalia для теминга Qt-приложений
    QT_QPA_PLATFORMTHEME = pkgs.lib.mkForce "qt6ct";
  };

  # --- GTK theming ---
  # Noctalia управляет GTK-темой в runtime через свои шаблоны.
  # HM задаёт базовый движок (adw-gtk3) и иконки — Noctalia пишет цвета поверх.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      package = yet-another-monochrome-icon-set;
      name = "yet-another-monochrome-icon-set";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    # qt6ct используется Noctalia для Qt-теминга
    platformTheme.name = "qt6ct";
  };

  # --- XDG dirs ---
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    # gtk-4.0/settings.ini: НЕ ставим force=true, чтобы Noctalia могла
    # управлять этим файлом в runtime через свои шаблоны.
    # Если нужно принудительно — раскомментировать:
    # configFile."gtk-4.0/settings.ini".force = true;
  };
}
