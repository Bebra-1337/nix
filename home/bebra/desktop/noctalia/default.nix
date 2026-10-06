{ ... }:

{
  # Устанавливаем пакет, настройки управляются через меню noctalia
  programs.noctalia.enable = true;

  # User templates: noctalia подхватывает все ~/.config/noctalia/*.toml
  xdg.configFile = {
    "noctalia/templates.toml".source = ./templates.toml;
    "noctalia/templates/vivaldi.css".source = ./vivaldi.css;
  };
}
