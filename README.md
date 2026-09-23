# nix — конфиг BEBRA-PC

Личный flake-конфиг NixOS + Home Manager. Один хост (`BEBRA-PC`), один
пользователь (`bebra`). Этот файл — шпаргалка на случай, если забудешь,
как тут всё устроено: где искать нужную настройку и как накатить изменения.

## Быстрый старт

```sh
nrs   # sudo nixos-rebuild switch --flake /home/bebra/nix#BEBRA-PC
nrt   # ...test  (то же самое, но без записи в загрузчик)
nrb   # ...boot  (применится после перезагрузки)
nfu   # nix flake update /home/bebra/nix
ngc   # sudo nix-collect-garbage --delete-older-than 14d
```
(алиасы объявлены в `home/bebra/cli/zsh/aliases.nix`)

Перед `switch` полезно сначала проверить, что конфиг вообще собирается,
не трогая живую систему:

```sh
nix flake check
nix build .#nixosConfigurations.BEBRA-PC.config.system.build.toplevel --no-link
```

### Два этапа установки (bootstrap → полный конфиг)

Если ставишь систему с нуля: сначала поднимается минимальный конфиг с
VPN и Hyprland, чтобы был интернет, потом — полный.

```sh
sudo nixos-rebuild switch --flake .#BEBRA-PC-bootstrap   # этап 1: только VPN + голый Hyprland
# запускаешь VPN, дальше интернет есть
sudo nixos-rebuild switch --flake .#BEBRA-PC             # этап 2: всё остальное
```

`BEBRA-PC-bootstrap` и `BEBRA-PC` — это один и тот же системный конфиг
(`hosts/BEBRA-PC/configuration.nix` + все `modules/system/*`), но с разным
home-manager модулем: `home/bebra/bootstrap.nix` (минимальный) или
`home/bebra/default.nix` (полный, импортирует всё остальное).

## Структура репозитория

```
flake.nix                     — входная точка: inputs, оверлеи, два вывода (BEBRA-PC / -bootstrap)
hosts/BEBRA-PC/
  configuration.nix           — только imports всех modules/system/* + stateVersion
  hardware-configuration.nix  — АВТОГЕНЕРИРУЕТСЯ (nixos-generate-config), руками не трогать
  themes/CyberGRUB-2077/      — тема GRUB
modules/system/                — системные (NixOS) модули, один файл — одна тема
home/bebra/
  default.nix                 — home-manager вход, полный конфиг (этап 2)
  bootstrap.nix                — home-manager вход, минимальный конфиг (этап 1)
  apps/                        — пакеты пользователя, по темам
  cli/                          — zsh, git, fastfetch
  desktop/                      — hyprland, kitty, noctalia
  theme/                        — gtk, qt
  services/                     — polkit
overlays/                      — кастомные/патченные пакеты (davinci-resolve, ida-pro, ...)
dotfiles/                      — файлы, не выражаемые как nix-опции (hyprland.lua, starship.toml)
secrets/, .sops.yaml            — sops-nix секреты (см. раздел "Секреты" ниже)
```

## Карта "хочу поменять X → открой файл Y"

### Система (NixOS, `modules/system/*.nix`)

| Тема | Файл |
|---|---|
| Загрузчик, GRUB, plymouth, kernelParams | `modules/system/boot.nix` |
| Сеть, hostname, firewall (общий), DNS (DoH) | `modules/system/networking.nix` |
| VPN (clash-verge, порты 9097/7895-7899, TUN) | `modules/system/vpn.nix` |
| GPU-железо (graphics/bluetooth), bluetooth-кодеки | `modules/system/hardware.nix` |
| NVIDIA-драйвер | `modules/system/nvidia.nix` |
| Звук (PipeWire) | `modules/system/audio.nix` |
| upower/power-profiles/xserver/gvfs/tumbler | `modules/system/desktop-services.nix` |
| Hyprland (сама сессия), greeter (noctalia), PAM hyprlock | `modules/system/desktop-session.nix` |
| SSH-агент, sshd | `modules/system/ssh.nix` |
| ghidra, ccache | `modules/system/dev-tools.nix` |
| kdeconnect, ydotool, nix-ld, dconf, thunar, xdg-portal | `modules/system/desktop-apps.nix` |
| Steam/gamemode/udev для геймпадов | `modules/system/gaming.nix` |
| Локаль, раскладка, часовой пояс | `modules/system/locale.nix` |
| Flatpak (Flathub, разрешения приложений) | `modules/system/flatpak.nix` |
| Секреты (sops-nix) | `modules/system/sops.nix` |
| Пользователь `bebra`, его группы | `modules/system/users.nix` |
| libvirtd/virt-manager | `modules/system/virtualisation.nix` |
| `environment.systemPackages` (общесистемные утилиты) | `modules/system/system-packages.nix` |
| `nix.settings`/`nix.gc`, allowUnfree | `modules/system/nix-settings.nix` |
| Kinect watchdog (⚠️ не трогать, см. ниже) | `modules/system/kinect-watchdog/` |

### Пользователь (Home Manager, `home/bebra/*`)

| Тема | Файл |
|---|---|
| zsh: сами опции zsh, plugins, history | `home/bebra/cli/zsh/default.nix` |
| Алиасы (`ls`, `gs`, `nrs`, ...) | `home/bebra/cli/zsh/aliases.nix` |
| Скрипты запуска шелла (env, keybindings, fastfetch, qtc()) | `home/bebra/cli/zsh/init.nix` |
| Starship-промпт | `home/bebra/cli/zsh/starship.nix` |
| fzf | `home/bebra/cli/zsh/fzf.nix` |
| git, ssh-алиасы хостов, direnv | `home/bebra/cli/git.nix` |
| fastfetch (баннер в терминале) | `home/bebra/cli/fastfetch.nix` |
| Hyprland (dotfiles-конфиг, fonts) | `home/bebra/desktop/hyprland.nix` |
| Kitty (настройки + Cyrillic-биндинги) | `home/bebra/desktop/kitty.nix` |
| Noctalia (wayland shell) | `home/bebra/desktop/noctalia.nix` |
| GTK-тема, иконки, курсор | `home/bebra/theme/gtk.nix` |
| Qt-тема (qt6ct) | `home/bebra/theme/qt.nix` |
| polkit-агент | `home/bebra/services/polkit.nix` |
| Браузер | `home/bebra/apps/browser.nix` |
| Файловый менеджер (доп. к thunar) | `home/bebra/apps/file-manager.nix` |
| GameDev (Godot) | `home/bebra/apps/gamedev.nix` |
| IDE/редакторы (IDA, Zed, QtCreator, CLion, ...) | `home/bebra/apps/ide.nix` |
| C/C++/Qt тулчейн | `home/bebra/apps/cpp-toolchain.nix` |
| Мессенджеры (Discord) | `home/bebra/apps/messaging.nix` |
| Рабочее (RustDesk, FreeCAD, DaVinci Resolve) | `home/bebra/apps/work.nix` |
| Скриншоты/запись экрана (Noctalia toolkit) | `home/bebra/apps/screen-capture.nix` |
| Инструменты тем/GUI (nwg-look, kvantum, ...) | `home/bebra/apps/theming-tools.nix` |
| Всё остальное (торренты, музыка, Minecraft, утилиты) | `home/bebra/apps/misc.nix` |

## Как добавить...

**...новый пакет в home-manager** — открой подходящий файл в `home/bebra/apps/`
(или `misc.nix`, если тема не подходит ни под один из существующих) и добавь
пакет в список `home.packages`.

**...новую системную опцию** — если она укладывается в одну из существующих
тем `modules/system/*.nix`, добавь туда. Если тема новая — создай новый файл
`modules/system/<тема>.nix` и добавь его в `imports` в
`hosts/BEBRA-PC/configuration.nix`.

**...новый overlay/патченный пакет** — файл в `overlays/`, подключается
через `nixpkgs.overlays` в `flake.nix`.

**...второй хост или пользователя** — `username`/`flakeDir` уже вынесены в
`specialArgs`/`extraSpecialArgs` в `flake.nix`, так что большая часть
модулей их переиспользует. Понадобится: новая папка `hosts/<имя>/` со своим
`configuration.nix` + `hardware-configuration.nix`, новый `home/<user>/`,
и новый вывод в `nixosConfigurations` в `flake.nix` (использовать `mkSystem`).

## Секреты (sops-nix)

Секреты лежат зашифрованными в `secrets/secrets.yaml`, ключи/правила — в
`.sops.yaml`. Расшифровка идёт через SSH-ключ хоста
(`/etc/ssh/ssh_host_ed25519_key`) или личный age-ключ
(`~/.config/sops/age/keys.txt`). Что расшифровывается и куда кладётся —
смотри `modules/system/sops.nix`.

## ⚠️ Хрупкие места — сначала думай, потом трогай

- **`modules/system/kinect-watchdog/`** — самодельная сборка (C-код,
  systemd-сервис, прошивка, udev-правила) для Kinect. Очень хрупкая,
  правится отдельно и осторожно, не в рамках общих правок конфига.
- **`hosts/BEBRA-PC/hardware-configuration.nix`** — автогенерируется
  командой `nixos-generate-config`. Если перегенерировать этот файл заново,
  ручные правки (например, отключённый `/mnt/games`) могут потеряться —
  после перегенерации обязательно свериться с git-diff.
- **DNS через DoH** (`modules/system/networking.nix`) захардкожен на
  конкретного провайдера (`eu.geohide.ru`). Если он ляжет — резолвинг DNS
  встанет, имей в виду при диагностике сетевых проблем.

## Известные пробелы (осознанно не сделано)

- Нет `.gitignore` — если когда-нибудь собирать без `--no-link`, не
  закоммить случайно символ-линк `result`.
- Нет автоформаттера/линтера (`nixfmt`/`treefmt`, `statix`, `deadnix`) —
  стиль между файлами может со временем разъехаться.
- Нет CI — `nix flake check` вручную перед `nrs`/`nrt` остаётся на тебе.
