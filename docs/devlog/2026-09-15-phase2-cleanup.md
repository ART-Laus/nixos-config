---
title: "Phase 2 cleanup — gaming, gamedev, thunderbird→ayugram, VLC, ranger→yazi, icon themes"
date: 2026-09-15
tags:
  - nixos
  - devlog
  - phase2
  - cleanup
  - packages
aliases:
  - "2026-09-15 phase2-cleanup"
related:
  - "[[devlog]]"
  - "[[2026-09-15-phase2]]"
  - "[[2026-09-15-architecture]]"
phase: 2
status: "✅ завершено"
commit: "e992101"
---

# 2026-09-15 — Phase 2 cleanup: gaming, gamedev, thunderbird→ayugram, VLC, ranger→yazi, icon themes

> [!info] Мета
> **Дата:** 2026-09-15 · **Тип:** `phase` · **Статус:** 🚧 в работе
> **Связано:** [[2026-09-15-phase2]]

## Цель

Выполнить пропущенный cleanup-этап: убрать gaming/gamedev мусор, заменить thunderbird на ayugram, добавить VLC, заменить ranger на yazi, очистить icon themes.

## Что сделано

### Gaming — Steam only
- **`system/gaming.nix`** — пересоздан. Удалены: `wineWowPackages`, `winetricks`, `steam-run`, `mangohud`, `protonup-qt`, весь Vulkan dev-набор (`vulkan-tools`, `vulkan-headers`, `dxvk`, `vkd3d`, `vkd3d-proton`, `gfxreconstruct`, `glslang`, `spirv-*`, `vkdisplayinfo`, `vk-bootstrap`), `programs.gamemode`, `programs.gamescope`. Остался только `programs.steam` с firewall-открытиями.
- **`home/features/gaming/default.nix`** — пересоздан. Удалены `mangohud`, `protonup-qt`. Осталось пусто (Steam управляется системно).
- **Зависимости**: `vulkan-loader` предоставляется `hardware.graphics.enable = true` в `boot-hardware.nix`. Дополнительные Vulkan-пакеты не нужны.

### Game Dev — удалён
- **`home/features/development/default.nix`** — удалены `godot`, `gdtoolkit_4`, `ldtk`.

### Browsers — thunderbird→ayugram
- **`home/features/desktop/browsers.nix`** — удалён `thunderbird`. Заменён `telegram-desktop` на `ayugram-desktop` (v7.0.9, найден в nixpkgs).

### Media — VLC добавлен
- **`home/features/media/default.nix`** — добавлен `vlc`. Удалён `mpv`.

### File Manager — ranger→yazi
- **`home/features/desktop/apps.nix`** — удалён `ranger`. Yazi уже настроен как `programs.yazi` в `home/features/cli/yazi.nix` с полной конфигурацией (тёмная неоновая тема, preview, архивы, изображения).

### Icon themes — cleanup
- **`system/packages.nix`** — удалены `material-icons`, `gruvbox-plus-icons`, `libsForQt5.breeze-icons` (дубли `kdePackages.breeze-icons`). Оставлены: `adwaita-icon-theme` (fallback), `papirus-icon-theme` (основной, Papirus-Dark в GTK), `kdePackages.breeze-icons` (Qt/KDE-приложения).

### Terminal — WezTerm → Alacritty + Kitty
- **`home/features/cli/terminal/wezterm.nix`** — удалён полностью (148 строк).
- **`home/features/cli/terminal/alacritty.nix`** — убран `shell.program = "wsl.exe"` (NixOS использует zsh). Сохранена неоновая тема.
- **`home/features/cli/terminal/kitty.nix`** — создан. Та же цветовая схема (Artlaus Neon) через `extraConfig`. Запасной терминал.
- **`home/features/cli/default.nix`** — `./terminal/wezterm.nix` → `./terminal/kitty.nix`.
- **`home/default.nix`** — `TERMINAL = "wezterm"` → `TERMINAL = "alacritty"`.
- **`home/features/desktop/compositor/hyprland.nix`** — `bind = $mainMod, Q, exec, wezterm` → `alacritty`.
- **`home/features/desktop/launcher/rofi.nix`** — `terminal = "${pkgs.wezterm}/bin/wezterm"` → `${pkgs.alacritty}/bin/alacritty`.
- **`home/features/cli/shell/zsh.nix`** — `TERMINAL = "alacritty"` уже был корректен.

## Открытые вопросы

- [ ] GUI файловый менеджер: `xfce.thunar` уже установлен и настроен в `system/services.nix`. Нужен ли он или хочет заменить?
- [ ] Icon themes: `adwaita-icon-theme` оставлен как fallback. Нужен ли?
- [ ] `nixos-rebuild build --flake .#msi-laptop` — проверить сборку на реальном железе
- [ ] GUI файловый менеджер: `xfce.thunar` уже установлен и настроен в `system/services.nix`. Нужен ли он или хочет заменить?
- [ ] Icon themes: `adwaita-icon-theme` оставлен как fallback. Нужен ли?

## Решения

- **Steam оставлен** — пользователь явно запросил
- **Ayugram выбран** — `ayugram-desktop` доступен в nixpkgs 25.05 (v7.0.9)
- **VLC заменяет mpv** — пользователь любит VLC
- **Yazi заменяет ranger** — Yazi уже полностью настроен с неоновой темой
- **Icon themes**: Papirus-Dark + Adwaita + Breeze — минимальный набор для Neon/Dark стиля

## Связи

- Предыдущая: [[2026-09-15-phase2]]
- Документация: [[architecture]]

## Следующий шаг

> [!todo] Phase 3 — `theme/` прошивка цветов через все компоненты

---

*Теги:* `#phase2` `#cleanup` `#gaming` `#ayugram` `#vlc` `#yazi` `#devlog`
*Связи:* `[[2026-09-15-phase2]]` · `[[2026-09-15-architecture]]`
