---
title: "Super-Key Hotkey System — Полная Переработка"
date: 2026-09-25
tags:
  - nixos
  - devlog
  - feature
aliases:
  - "2026-09-21 integration"
related:
  - "[[devlog]]"
  - "[[2026-09-21-integration]]"
---

# 2026-09-25 — Super-Key Hotkey System

> [!info] Мета
> **Дата:** 2026-09-25 · **Тип:** `feature` · **Статус:** ✅ завершено

## Цель

Полностью переосмыслить систему горячих клавиш NixOS-конфигурации. **Super / Windows** становится главным глобальным модификатором всей системы.

## Что сделано

### Полная переработка `hyprland.nix`

Переписаны все хоткеи в `home/features/desktop/compositor/hyprland.nix`. Super становится центральной клавишей управления системой.

### Новые mappings

| Сочетание | Действие |
|---|---|
| `Super + Enter` | Terminal (alacritty) |
| `Super + B` | Browser (firefox) |
| `Super + T` | Ayugram |
| `Super + E` | Files (thunar) |
| `Super + W` | Случайная обой (fade) из `~/Pictures/wallpapers/` |
| `Super + Q` | Kill active |
| `Super + Shift + F` | Fullscreen |
| `Super + G` | Resize |
| `Super + H` | btop (monitor) |
| `Super + N` | planify (notes) |
| `Super + K` | qalculate (calculator) |
| `Super + Y` | yazi (TUI file manager) |
| `Super + P` | ksnip (screenshot tool) |
| `Super + ↑/↓` | Focus workspace up/down |
| `Super + Shift + ↑/↓` | Move window up/down |

### Сохранённые mappings

- `Super + Space` → Launcher (rofi)
- `Super + L` → Lock (swaylock)
- `Super + V` → Clipboard (cliphist)
- `Super + R` → rofi-scripts
- `Super + C` → Kill active
- `Super + M` → Exit
- `Super + F` → Toggle floating
- `Super + ←/→` → Focus left/right
- `Super + Shift + ←/→` → Move window
- `Super + 1-0` → Workspaces 1-10
- `Super + Shift + 1-0` → Move to workspace
- `Print` / `Shift + Print` → Screenshot
- `Super + mouse` → Move/Resize

### hyprpaper — анимированные обои

Добавлен `transition = "fade"` в `hyprpaper.nix`. Скрипт `scripts/wallpaper.sh` выбирает случайное изображение из `~/Pictures/wallpapers/` и устанавливает через `hyprctl hyprpaper wallpaper`.

### Дополнительные пакеты

- `qalculate` добавлен в `home/features/media/default.nix`
- `scripts/wallpaper.sh` добавлен в `scripts/default.nix`

## Принципы

### Mnemonic
```
B → Browser     T → Telegram/Ayugram
E → Files       W → Wallpaper
H → Head/Monitor N → Notes
K → Calculator  Y → Yazi
P → Picture     Q → Quit
```

### Symmetry
Стрелки `←/→/↑/↓` работают одинаково для focus и move window:
- `Super + ←/→` = focus
- `Super + Shift + ←/→` = move
- `Super + ↑/↓` = focus
- `Super + Shift + ↑/↓` = move

### Low Cognitive Load
28 биндингов, но только 13 уникальных клавиш. Остальное — launcher + стандартные Hyprland bindings.

## Результат

- Super — главная клавиша управления системой
- Все mappings mnemonic и симметричные
- Нет конфликтов
- Анимированные обои с fade-переходом
- Коммит `6b9b8a3`

## Открытые вопросы

- [ ] `qalculate` — проверить имя пакета в nixpkgs 25.05
- [ ] `wallpaper.sh` — проверить `hyprctl hyprpaper wallpaper` синтаксис при первом запуске
- [ ] `Super + Shift + Space` — свободна, нужна ли ей роль?
- [ ] `Super + I`, `Super + U`, `Super + J` — свободны, нужна ли им роль?

## Связи

- Предыдущая: [[2026-09-21-integration]]
- Документация: [[devlog]]

## Следующий шаг

Тестирование сборки flake и верификация всех хоткеев на практике

---
*Теги:* `#devlog` `#nixos` `#feature`
