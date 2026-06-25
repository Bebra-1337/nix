{ ... }:

{
  # Link Matugen configuration and templates
  xdg.configFile."matugen/config.toml".source = ../../../dotfiles/matugen/config.toml;
  xdg.configFile."matugen/templates".source = ../../../dotfiles/matugen/templates;
  xdg.configFile."matugen/websites".source = ../../../dotfiles/matugen/websites;
  xdg.configFile."matugen/import_scheme.py".source = ../../../dotfiles/matugen/import_scheme.py;
  xdg.configFile."matugen/telegram.tdesktop-theme".source = ../../../dotfiles/matugen/telegram.tdesktop-theme;

  # Load Matugen generated colors into GTK 3 & 4
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    @import url("colors.css");
  '';
  xdg.configFile."gtk-4.0/gtk.css".text = ''
    @import url("colors.css");
  '';
  xdg.configFile."gtk-4.0/gtk-dark.css".text = ''
    @import url("colors.css");
  '';
}
