---
title: "Интеграция 24 инструментов Discovery Expansion"
date: 2026-09-21
tags:
  - nixos
  - devlog
  - feature
aliases:
  - "2026-09-21 integration"
related:
  - "[[devlog]]"
  - "[[2026-09-21-discovery-expansion]]"
---

# 2026-09-21 — Интеграция 24 инструментов Discovery Expansion

> [!info] Мета
> **Дата:** 2026-09-21 · **Тип:** `feature` · **Статус:** ✅ завершено

## Цель

Интегрировать 24 выбранных инструмента из Discovery Expansion в модульный NixOS/Home Manager конструктор (`~/nixos-config`).

## Что сделано

- Переписан `home/features/cli/tools.nix` — все 24 инструмента интегрированы
- Обновлён `flake.nix` — добавлены 8 flake inputs (nixmate, nixard, verynix, anima, super-comma, nixy, niux, nix-bonsai)
- Добавлен `flakePkgs` в `specialArgs` для доступа к flake-пакетам из модулей
- Исправлен `flake.lock` — обновлён автоматически

### Замена нерабочих механизмов (nixos-25.05 breaking changes)

| Удалено | Замена |
|---|---|
| `pkgs.cargoInstall` | `pkgs.runCommand` + `cargo install --root $out` |
| `pkgs.nodePackages` | `pkgs.runCommand` + `pnpm add --prefix $out` |

### Распределение инструментов по способам установки

- **`cargo install`** (8): px2ansi-rs, vinz, tuitab, tooi, bitchat-tui, puls, nix-pretty, coretilus
- **`flakePkgs`** (8): anima, nixmate, nixard, verynix, super-comma, nixy, niux, nix-bonsai
- **`pnpm`** (2): phosphor, milli
- **`pkgs` напрямую** (6): timg, notcurses + ранее установленные

### Дополнительно

- Добавлены алиасы `aln` и `nn` в `home/features/cli/shell/zsh.nix`
- Обновлена `theme/colors.nix` — `shadow` формат `rgba(00000066)`

## Результат

- Все 24 инструмента доступны через `home.packages`
- Flake выражение корректно оценивается (`nix-instantiate` без ошибок)
- `cargo install` компилирует Rust-пакеты при первой сборке (несколько минут)
- Коммит `8408d02`

## Решения

- **`cargo install` вместо `rustPlatform.buildRustPackage`** — проще, не требует знания версий и hash'ей с crates.io
- **`pnpm` вместо `npm`** — `npm` отсутствует в nixpkgs 25.05, `pnpm` доступен
- **`runCommand` для всех кастомных пакетов** — единый подход, работает с любым package manager

## Открытые вопросы

- [ ] Время первой сборки с `cargo install` — может быть длительным
- [ ] `pnpm add --prefix` для scoped пакетов (`@amansingh-afk/milli`) — требует проверки
- [ ] `phosphor` и `milli` — npm-пакеты, нужно проверить корректность установки

## Связи

- Предыдущая: [[2026-09-21-discovery-expansion]]
- Документация: [[devlog]]

## Следующий шаг

Phase 4 — тестирование сборки flake и верификация всех 24 инструментов

---
*Теги:* `#devlog` `#nixos` `#feature`
