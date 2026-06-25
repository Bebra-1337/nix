{ pkgs, ... }:

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
  # --- Pointer cursor ---
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Original-Ice";
    size = 24;
  };

  # --- GTK theming ---
  # Matugen управляет GTK-темой в runtime через свои шаблоны.
  # HM задаёт базовый движок (adw-gtk3) и иконки — Matugen пишет цвета поверх.
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
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # --- XDG dirs ---
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    configFile."xfce4/helpers.rc".text = "TerminalEmulator=kitty\n";

    # gtk-4.0/settings.ini: НЕ ставим force=true, чтобы Matugen могла
    # управлять этим файлом в runtime через свои шаблоны.
    # Если нужно принудительно — раскомментировать:
    # configFile."gtk-4.0/settings.ini".force = true;
  };
}
