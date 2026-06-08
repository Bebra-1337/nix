# Установка BEBRA-PC

## Что нужно заранее

Чистая NixOS (без DE) с доступом в интернет. Git:
```bash
nix-env -iA nixos.git
```

---

## 1. Клонировать конфиг

```bash
git clone https://github.com/YOUR_REPO/nix.git ~/nix
```

---

## 2. Скопировать hardware-configuration.nix

```bash
cp /etc/nixos/hardware-configuration.nix ~/nix/hosts/BEBRA-PC/hardware-configuration.nix
```

Открой файл и добавь если нет:
```nix
zramSwap = { enable = true; memoryPercent = 25; };
```

---

## 3. Stage 1 — Bootstrap (Hyprland + VPN)

```bash
sudo nixos-rebuild switch --flake ~/nix#BEBRA-PC-bootstrap
```

После перезагрузки: Ly покажет TUI, войди — запустится Hyprland.

Запусти Clash Verge Rev (`Super+Space`), добавь подписку, включи TUN mode.

---

## 4. Stage 2 — Полный конфиг

```bash
sudo nixos-rebuild switch --flake ~/nix#BEBRA-PC
```

Устанавливает всё: Noctalia, все приложения, шрифты, стек разработки.

---

## Алиасы (доступны после Stage 1)

| Алиас | Действие |
|-------|----------|
| `nrs` | nixos-rebuild switch |
| `nrt` | nixos-rebuild test |
| `hms` | home-manager switch |
| `nfu` | nix flake update |
| `ngc` | очистить поколения старше 14 дней |

---

## Обои

Положи файл в `~/Pictures/Wallpapers/wallpaper.jpg` (путь в `dotfiles/hypr/hyprpaper.conf`).  
Noctalia сгенерирует цветовую схему автоматически.
