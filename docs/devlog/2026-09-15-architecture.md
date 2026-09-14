---
title: "Архитектурное предложение — модульный конструктор"
date: 2026-09-15
tags:
  - nixos
  - devlog
  - architecture
  - features
  - theme
aliases:
  - "2026-09-15 architecture"
related:
  - "[[devlog]]"
  - "[[2026-09-14-audit]]"
  - "[[2026-09-15-neovim]]"
decisions:
  - "flat + features"
  - "theme/ в корне"
  - "greetd"
  - "Lazy.nvim"
---

# 2026-09-15 — Архитектурное предложение

> [!info] Мета
> **Дата:** 2026-09-15 · **Тип:** `architecture` · **Статус:** ✅ утверждено
> **Решения:** `плоская структура + features/` · `theme/` в корне · `greetd` · `Lazy.nvim`

## Цель

Спроектировать систему как **конструктор из независимых кубиков** с feature flags и слабой связанностью. Учесть доп. требования: локальность ответственности, discoverability, без Enterprise Java.

## Что сделано

- Сформулированы 10 приоритетов: Понятность > Модульность > Независимость > Воспроизводимость > ...
- Спроектировано целевое дерево (FLAT + `features/` как инкубатор):
  - `hosts/msi-laptop/` — один хост = одна папка
  - `system/` — 6 плоских файлов (`nix.nix`, `boot-hardware.nix`, `networking-security.nix`, `services.nix`, `gaming.nix`, `packages.nix`)
  - `home/` — 8 плоских файлов + `features/neovim/` (единственный сложный кубик)
  - `theme/` — в корне, через `specialArgs.theme`
  - `lib/theme.nix` — чистые функции
- Описана ответственность каждой папки + «чего там быть не должно»
- Введены feature flags через `mkEnableOption` + `mkIf` (нативно, без фабрик)
- Построен Dependency Graph: `theme/ → Core → CLI/Desktop/Dev → Neovim`; правила `Desktop ↛ CLI`, `CLI ↛ Desktop`
- Составлена Feature Matrix (15 фич, System/Home, зависимости, файлы)
- Разобран монолит `system/packages.nix` (266 строк) и `cli/default.nix` (196) → план декомпозиции
- Migration Plan: 13 переносов (Было → Станет → Почему)
- Ответ на финальный вопрос: «максимальная модульность — да, но достаточная»
- Централизация Theme: `theme/colors.nix` → `specialArgs.theme`

> [!success] Артефакт
> `docs/architecture.md` — 10 разделов, дерево, граф, матрица, migration plan. Обновлён под **flat** после утверждения 2026-09-15.

## Решения (утверждены пользователем 2026-09-15)

| Вопрос | Решение |
|---|---|
| Структура | **Плоская** + `features/` сохраняется как инкубатор |
| `theme/` | **В корне** (`theme/colors.nix` → `specialArgs.theme`) |
| Display manager | **greetd** + `tuigreet` (Wayland-native, минималистичный) |
| Neovim manager | **Lazy.nvim** (см. [[2026-09-15-neovim]]) |
| Правило расщепления | `< 200 строк` — плоско; `> 200 строк` — в `features/` |

> [!quote] Принцип эволюции
> `home/desktop.nix` < 200 строк → плоско. Как вырастет → `home/features/desktop/{hyprland,waybar,rofi,dunst}.nix` без breaking change (меняется один `imports`).

## Открытые вопросы

- [x] Утвердить дерево → ✅ плоско + features
- [x] Где `theme/` → ✅ в корне
- [x] Display manager → ✅ greetd
- [ ] Начинать ли Phase 1 (hosts + nix.nix + theme) — ждёт старта рефакторинга

## Связи

- Предыдущая: [[2026-09-14-audit]]
- Параллельная: [[2026-09-15-neovim]]
- Документация: `[[architecture]]`

## Следующий шаг

Исследование Neovim → [[2026-09-15-neovim]] → затем Phase 1 рефакторинга

---

*Теги:* `#nixos` `#architecture` `#features` `#theme` `#devlog`
