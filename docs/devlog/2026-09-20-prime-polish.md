---
title: "Prime Polish — audit и первые правки"
date: 2026-09-20
tags:
  - nixos
  - devlog
  - prime-polish
aliases:
  - "2026-09-20 prime-polish"
related:
  - "[[devlog]]"
  - "[[2026-09-18-phase3b]]"
---

# 2026-09-20 — Prime Polish: Audit и первые правки

> [!info] Мета
> **Дата:** 2026-09-20 · **Тип:** `feature` · **Статус:** ✅ evaluation OK

## Цель

Провести полный аудит существующей системы и начать устранение найденных проблем. Не добавлять новые инструменты — только улучшать существующее.

## Аудит

Полный аудит всех конфигов: `flake.nix`, `hosts/`, `system/`, `home/`, `home/features/`, `theme/`.

Найдено:
- 10+ файлов с хардкодными цветами вместо `theme.colors`
- 5+ файлов с мёртвой конфигурацией
- Конфликт `oh-my-zsh` + `antidote`
- `nil` в packages (отсутствует в pkgs 25.05)
- `lspsaga` дублирован в Neovim
- Несогласованность названий шрифтов
- `waybar` — `output` хардкод, `memory`/`cpu` модули не подключены

## Что сделано

### Theme consistency

- **Starship** (`home/features/cli/shell/starship.nix`): заменены все хардкодные цвета на `theme.colors`. Добавлены 4 новых цвета в палитру: `lightGreen`, `mint`, `brightGreen`, `seaGreen`
- **Zsh** (`home/features/cli/shell/zsh.nix`): `FZF_DEFAULT_OPTS` теперь через `theme.colors`
- **Tmux** (`home/features/cli/tmux.nix`): все цвета статус-бара через `theme.colors`
- **Git** (`home/features/cli/git.nix`): `color.branch/diff/status` через `theme.colors`
- **Waybar style** (`home/features/desktop/bar/style.nix`): все `rgba(...)` заменены на `theme.colors`. Добавлены прозрачные варианты в `theme/colors.nix`: `secondaryTransparent`, `fgTransparent`, `warningTransparent`, `accentBlueTransparent`, `errorTransparent`, `successTransparent` и т.д.
- **Hyprland** (`home/features/desktop/compositor/hyprland.nix`): `col.shadow` через `theme.colors`. Добавлен `c = theme.colors` в `let`
- **Шрифты**: `alacritty.nix`, `kitty.nix`, `gtk-qt.nix`, `style.nix` приведены к `theme/fonts.nix`

### Architecture cleanup

- **Zsh** (`home/features/cli/shell/zsh.nix`): убран `antidote`, переход на `oh-my-zsh` с `plugins`. Убраны `autosuggestion.enable` и `syntaxHighlighting.enable` (дублируют oh-my-zsh)
- **Development** (`home/features/development/default.nix`): удалён `nil` (отсутствует в pkgs 25.05)
- **Neovim LSP** (`home/features/cli/neovim/lua/plugins/lsp.nix`): убран `lspsaga` из `dependencies` (уже подключается через `lspsaga.nix`)

### Waybar

- **Waybar** (`home/features/desktop/bar/waybar.nix`): убран хардкод `output = "DP-1"`. Добавлены `memory` и `cpu` в `modules-left`

### Cleanup

- **Neofetch** (`home/features/cli/neofetch.nix` + `tools.nix`): убран `fastfetch`, оставлен только `neofetch`
- **Browsers** (`home/features/desktop/browsers.nix`): убраны `chromium`, `librewolf`. `discord`, `ayugram-desktop` перенесены в `apps.nix`. Остался только `firefox`
- **Apps** (`home/features/desktop/apps.nix`): добавлены `discord`, `ayugram-desktop`

## Результат

- `nix flake check` проходит без ошибок
- Все основные компоненты используют единый источник цветов `theme/colors.nix`
- Удалена мёртвая конфигурация
- Конфликтующие компоненты устранены

## Открытые вопросы

- [ ] Шрифты: `alacritty.nix`/`kitty.nix` используют `"JetBrains Mono"` вместо `"JetBrainsMono Nerd Font"` из `fonts.nix`
- [ ] `gtk-qt.nix`: размер шрифта `"JetBrainsMono Nerd Font 11"` vs `fonts.nix` `size = 14`
- [ ] `style.nix`: `font-family` хардкод `"JetBrainsMono Nerd Font"` вместо `theme.fonts.ui.name`
- [ ] `hyprland.nix`: `toRgba` функция по-прежнему используется, но `c` теперь доступен — можно упростить
- [ ] `neofetch.nix`: `neofetch` + `fastfetch` дублирование
- [ ] `tools.nix`: `fastfetch` + `neofetch` дублирование
- [ ] `zsh.nix`: `GOOGLE_CLOUD_PROJECT`, `NVM_DIR`, `flakeDir` хардкод путей
- [ ] `apps.nix`: `qmk` + `vial` дублирование
- [ ] `browsers.nix`: 3 браузера
- [ ] `media.nix`: `vlc` + `strawberry` + `obs-studio`

## Связи

- Предыдущая: [[2026-09-18-phase3b]]
- Документация: [[architecture]]

## Следующий шаг

Продолжить Prime Polish: шрифты, дублирование, хардкод путей.

---
*Теги:* `#devlog` `#nixos` `#prime-polish`