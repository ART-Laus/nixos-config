---
title: Девлог — NixOS конструктор
tags:
  - nixos
  - devlog
  - index
aliases:
  - devlog
cssclass: devlog-index
---

# Девлог — NixOS конструктор

> [!info] О формате
> Каждая запись — отдельная заметка в `docs/devlog/` с YAML-frontmatter. Этот файл — **индекс**. Совместим с **Obsidian** (Dataview, Wikilinks, Tags).
>
> - Создать запись: `docs/devlog/YYYY-MM-DD-slug.md` с frontmatter `title/date/tags`
> - Связи: `[[2026-09-14-audit]]` · Теги: `#devlog` `#nixos`
> - Шаблон — внизу файла

---

## Оглавление (Dataview)

> [!tip] Для Obsidian с плагином Dataview — автотаблица
> Если Dataview не установлен, смотри ручной список ниже.

```dataview
TABLE date as Дата, tags as Теги, decision as Решение
FROM "docs/devlog"
SORT date DESC
```

---

## Хронология (ручной индекс)

| Дата | Заметка | Тип | Статус |
|---|---|---|---|
| 2026-09-14 | [[2026-09-14-audit\|Аудит существующего конфига]] | `audit` | ✅ завершено |
| 2026-09-15 | [[2026-09-15-architecture\|Архитектурное предложение]] | `architecture` | ✅ утверждено |
| 2026-09-15 | [[2026-09-15-neovim\|Исследование Neovim — выбор Lazy.nvim]] | `research` | ✅ решено |
| 2026-09-15 | [[2026-09-15-decisions\|Решения: flat + greetd + Lazy + Obsidian]] | `decision` | ✅ утверждено |
| 2026-09-15 | [[2026-09-15-phase1\|Phase 1 — полная иерархия features сразу]] | `phase` | ✅ evaluation OK |
| 2026-09-15 | [[2026-09-15-packages\|Миграция packages.legacy → features]] | `packages-migration` | ✅ завершено |
| 2026-09-15 | [[2026-09-15-phase2\|Phase 2 — удаление artlaus/, nix flake check, фикс devShell]] | `phase` | ✅ evaluation OK |
| 2026-09-15 | [[2026-09-15-phase2-cleanup\|Phase 2 cleanup — gaming, gamedev, thunderbird→ayugram, VLC, ranger→yazi, icon themes, terminal→alacritty+kitty]] | `phase` | ✅ завершено |
| 2026-09-15 | [[2026-09-15-phase3\|Phase 3 — theme/ прошивка цветов через все компоненты]] | `phase` | ✅ evaluation OK |
| 2026-09-18 | [[2026-09-18-add-vpn\|Добавлены Tor, OpenVPN, Tailscale, Docker]] | `feature` | ✅ evaluation OK |
| 2026-09-18 | [[2026-09-18-phase3b\|Phase 3b — theme/ прошивка цветов в Neovim-плагины + сервисы]] | `feature` | ✅ evaluation OK |

---

## Встраивание (Obsidian Embeds)

> [!note] Быстрый просмотр без перехода
> В Obsidian эти секции рендерятся inline.

### ![[2026-09-14-audit#Цель]]

### ![[2026-09-15-architecture#Цель]]

### ![[2026-09-15-neovim#Цель]]

---

## Граф связей

```mermaid
graph LR
  A[2026-09-14-audit] --> B[2026-09-15-architecture]
  B --> C[2026-09-15-neovim]
  B --> D[2026-09-15-decisions]
  C -.-> D
  D --> P1[2026-09-15-phase1]
  P1 --> PK[2026-09-15-packages]
  P1 --> P2[2026-09-15-phase2]
```

---

## Шаблон новой записи

> [!todo] Скопируй в `docs/devlog/YYYY-MM-DD-slug.md`

```markdown
---
title: "Краткий заголовок"
date: YYYY-MM-DD
tags:
  - nixos
  - devlog
aliases:
  - "YYYY-MM-DD slug"
related:
  - "[[devlog]]"
---

# YYYY-MM-DD — Заголовок

> [!info] Мета
> **Дата:** YYYY-MM-DD · **Тип:** `feature|fix|research` · **Статус:** 🚧 в работе

## Цель

## Что сделано
-

## Результат

## Решения

## Открытые вопросы
- [ ]

## Связи
- Предыдущая: [[...]]
- Документация: [[architecture]]

## Следующий шаг

---
*Теги:* `#devlog`
```

---

## Статистика

- Всего записей: `11`
- Последняя: [[2026-09-18-phase3b]] (2026-09-18)
- Следующая фаза: `Phase 4 — ...` (см. [[architecture#10. Следующие шаги (обновлено)|architecture]])

---

*Индекс обновлён: 2026-09-15 · Формат: Obsidian + Dataview + Wikilinks*
