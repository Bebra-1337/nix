{ ... }:

{
  # --- Starship prompt — native TOML config (цвета управляются Noctalia) ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # Указываем активную палитру (файл с цветами подключается динамически ниже)
    settings = builtins.fromTOML (builtins.readFile ../../../../dotfiles/starship.toml) // {
      palette = "noctalia";
    };
  };
}
