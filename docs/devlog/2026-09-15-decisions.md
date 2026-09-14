---
title: "Решения по архитектуре — flat + greetd + Lazy + Obsidian"
date: 2026-09-15
tags:
  - nixos
  - devlog
  - architecture
  - decision
aliases:
  - "2026-09-15 decisions"
related:
  - "[[devlog]]"
  - "[[2026-09-15-architecture]]"
  - "[[2026-09-15-neovim]]"
  - "[[architecture]]"
decisions:
  - "flat + features (инкубатор)"
  - "theme/ в корне"
  - "greetd + tuigreet"
  - "Lazy.nvim"
  - "Obsidian devlog"
---

# 2026-09-15 — Решения по архитектуре

> [!info] Мета
> **Дата:** 2026-09-15 · **Тип:** `decision` · **Статус:** ✅ утверждено
> Ответы на вопросы из [[2026-09-15-architecture]] и [[2026-09-15-neovim]]

## Вопросы и ответы

| Вопрос | Ответ | Обоснование |
|---|---|---|
| Структура | **Плоская + `features/` как инкубатор** | Один хост, 6+8 файлов читаются за 10с. `features/` сохраняется для сложных кубиков (сейчас только `neovim/`). Правило: `<200 строк` — плоско, `>200` — в `features/`. |
| `theme/` | **В корне** | Доступен и `system` (greetd) и `home` (waybar/nvim) через `specialArgs.theme` |
| Display manager | **greetd + tuigreet** | Wayland-native, 5МБ, без Qt/X11, минимализм в духе Neon Green / Dark. SDDM — 80МБ + Qt, оставил бы как флаг `sddm` если понадобится графический логин. |
| Neovim | **Lazy.nvim** | `vim.pack` пока без `event/keys/dependencies` DSL → спека и конфиг в разных файлах. Lazy даёт `один файл = один плагин` → ваша цель discoverability. `vim.pack` — ветка для эксперимента. |
| Девлог | **Obsidian: заметка + индекс** | Каждая запись — `docs/devlog/YYYY-MM-DD-slug.md` с frontmatter, индекс — `docs/devlog.md` с Dataview + embeds |

## Что сделано сегодня

- [x] `docs/architecture.md` обновлён под flat + `features/` + `theme/` в корне + `greetd` + `Lazy`
- [x] `docs/neovim.md` — добавлен §6, статус утверждено Lazy
- [x] `docs/devlog.md` — переделан в Obsidian-индекс (frontmatter, Dataview, embeds, Mermaid)
- [x] `docs/devlog/` — 3 заметки уже + эта (4-я)
- [x] `theme/colors.nix`, `theme/fonts.nix`, `theme/default.nix` — созданы, палитра Artlaus Neon
- [x] `lib/theme.nix` — хелпер `toRgba`
- [x] `home/features/README.md` — правило инкубатора

## Структура после решений

```text
theme/               # ← в корне, specialArgs.theme
home/features/       # ← инкубатор (сейчас только neovim/)
  README.md
  neovim/
system/              # ← плоско: 6 файлов
home/                # ← плоско: 8 файлов + features/
```

См. полный граф: [[architecture#2. Proposed Architecture|architecture]]

## Следующий шаг

> [!todo] Phase 1
> `hosts/msi-laptop/` + `system/nix.nix` + `flake.nix` (specialArgs, 25.05) + `theme/` интеграция
> Требует `nixos-generate-config` на реальном железе для `hardware-configuration.nix`

---

*Теги:* `#nixos` `#decision` `#devlog`
