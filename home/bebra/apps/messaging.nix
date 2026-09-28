{ pkgs, ... }:

let
  # DEV: Vencord из локального клона с плагином discord-overlay
  # (/home/bebra/discord-overlay/.vencord, пересборка — scripts/install-vencord-plugin.sh).
  # Нечистая ссылка за пределы /nix/store: после `pnpm build` достаточно перезапустить Discord.
  # Чтобы вернуть Vencord из nixpkgs — удалить этот let и строку `vencord = vencordDev;`.
  vencordDev = pkgs.runCommand "vencord-dev" { } ''
    ln -s /home/bebra/discord-overlay/.vencord/dist $out
  '';
in
{
  # Vulkan-слой оверлея (64 и 32 бит). Discord пока на dev-сборке Vencord ниже;
  # когда плагин устоится — discord.enable = true вместо vencordDev.
  programs.discord-overlay.enable = true;

  home.packages = with pkgs; [
    (discord.override {
      withVencord = true;
      vencord = vencordDev;
      withOpenASAR = false; # faster app.asar replacement
    })
  ];
}
