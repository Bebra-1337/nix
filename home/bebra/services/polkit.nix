{ pkgs, ... }:

# Hyprland Polkit Agent — общий модуль для bootstrap и full конфигурации.
# Устанавливает пакет и регистрирует systemd user service.
{
  home.packages = [ pkgs.hyprpolkitagent ];

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
