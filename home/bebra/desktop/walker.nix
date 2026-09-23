{ ... }:

{
  # Walker (github.com/abenz1267/walker) + elephant (бэкенд-провайдер данных) —
  # тот же лаунчер, что использует Omarchy. Здесь только пакеты и systemd-юниты —
  # сам конфиг и тема живут обычными файлами в ~/.config/walker/ (НЕ через
  # xdg.configFile), чтобы их можно было часто править без ребилда/switch:
  #   ~/.config/walker/config.toml
  #   ~/.config/walker/themes/omarchy/{layout.xml,style.css}
  # После правки XML нужен `systemctl --user restart walker`, CSS подхватывается
  # без рестарта.
  services.elephant.enable = true;

  services.walker = {
    enable = true;
    systemd.enable = true;
  };

  # На части систем с NVIDIA GTK4-рендерер ngl мигает/артефактит —
  # Omarchy форсирует cairo для walker, делаем так же. Если проблем нет —
  # можно убрать.
  systemd.user.services.walker.Service.Environment = "GSK_RENDERER=cairo";
}
