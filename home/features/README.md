---
title: features — инкубатор модулей
tags: [nixos, architecture, features]
---

# `home/features/` — инкубатор

> [!info] Зачем эта папка, если структура плоская?
> Плоская структура (`home/*.nix`) — для 90% случаев (один хост, <200 строк на файл).
> `features/` — **инкубатор** для сложных кубиков, которые уже выросли.

## Правило

```text
home/desktop.nix  < 200 строк  →  остаётся в home/*.nix (плоско)
home/desktop.nix  > 200 строк  →  расщепить → home/features/desktop/{hyprland.nix, waybar.nix, rofi.nix}
```

**Сейчас в `features/`:**

| Папка | Почему уже в features |
|---|---|
| `neovim/` | 30 плагинов + Lua-дерево `nvim/` — уже >200 строк, нужен `lazy-lock.json` |

**Когда выносить:**

- `home/gaming.nix` → `features/gaming/` когда добавите 5+ gaming-инструментов
- `home/desktop.nix` → `features/desktop/` когда Waybar/Rofi/Dunst потребуют своих тем
- `home/development.nix` → `features/development/` когда языков >3

## Как выносить

```nix
# Было: home/default.nix
imports = [ ./desktop.nix ];

# Стало: home/default.nix
imports = [ ./features/desktop ];
# home/features/desktop/default.nix  →  imports = [ ./hyprland.nix ./waybar.nix ... ];
```

Никакого Enterprise Java — просто `imports`.

## Связи

- Архитектура: [[architecture#2. Proposed Architecture|architecture]]
- Девлог: [[devlog]]
