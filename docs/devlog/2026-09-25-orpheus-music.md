---
title: "Project Orpheus — Музыкальная Система"
date: 2026-09-25
tags:
  - nixos
  - devlog
  - feature
aliases:
  - "2026-09-25 orpheus music"
related:
  - "[[devlog]]"
  - "[[2026-09-25-super-key-hotkeys]]"
---

# 2026-09-25 — Project Orpheus — Музыкальная Система

> [!info] Мета
> **Дата:** 2026-09-25 · **Тип:** `feature` · **Статус:** ✅ завершено

## Цель

Настроить NixOS-систему для работы с музыкальным проектом **Project Orpheus** — личной музыкальной библиотекой (23,052 трека, 7,871 альбомов) с Docker-сервисами.

## Что сделано

### Docker включён

- `system/virtualization.nix` — `features.virtualization.enable = true`
- Добавлен `cifs-utils`, `smbclient` для SMB-монтирования
- Docker включён на загрузку (`enableOnBoot = true`)
- Автоочистка неиспользуемых образов (`autoPrune`)

### SMB-монтирование библиотеки

- `home/features/desktop/orpheus/mounts/library.nix`
- Монтирует `E:/Library` с ноутбука через SMB over Tailscale
- Точка монтирования: `/home/artlaus/Music`
- Создаёт системный сервис `orpheus-library-mount`
- Шаблон учётных данных в `~/.config/orpheus/smb-credentials`

### Docker-сервисы

- **Navidrome** (порт 4533) — музыкальный сервер
  - Том: `/home/artlaus/Music:/music:ro`
  - Данные: `data/navidrome/`
  - Сканирование каждые 5 минут
- **FileBrowser** (порт 8080) — файловый менеджер
  - Том: `/home/artlaus/Music:/srv/Music`
  - БД: `data/filebrowser.db`

### Python venv

- `.venv` в проекте уже существовал
- Установлены зависимости: `orpheus`, `spotipy`, `pyyaml`, `pycryptodome`, `mutagen`, `pytest`
- `orpheus` CLI доступен: `source .venv/bin/activate && orpheus --help`

### Символические ссылки

- `project` → `/mnt/c/Users/user/Desktop/ART_mytrash/Project_Orpheus`
- `Music` → `/home/artlaus/Music`

### Проект не изменён

Вся настройка на уровне системы. `docker-compose.yml`, `pyproject.toml`, `.env` — не трогались.

## Результат

- Docker готов к запуску Navidrome и FileBrowser
- SMB-монтирование настроено (требует указания IP ноутбука)
- Python-проект работает
- Коммит `0dca5f9`

## Открытые вопросы

- [ ] Указать реальный хостнейм/IP ноутбука в `library.nix` (`LAPTOP-HOST`)
- [ ] Заполнить SMB-учётные данные в `~/.config/orpheus/smb-credentials`
- [ ] Запустить `systemctl --user start orpheus-library-mount`
- [ ] Запустить `systemctl --user start orpheus-navidrome`
- [ ] Запустить `systemctl --user start orpheus-filebrowser`

## Связи

- Предыдущая: [[2026-09-25-super-key-hotkeys]]
- Документация: [[devlog]]

## Следующий шаг

Заполнить учётные данные и запустить сервисы

---
*Теги:* `#devlog` `#nixos` `#feature`
