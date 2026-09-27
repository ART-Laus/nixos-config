---
title: "Automation Layer — Этап 2: Реализация"
date: 2026-09-27
tags:
  - nixos
  - devlog
  - feature
aliases:
  - "2026-09-27 automation layer implementation"
related:
  - "[[devlog]]"
  - "[[2026-09-27-automation-layer-audit]]"
---

# 2026-09-27 — Automation Layer: Этап 2 — Реализация

> [!info] Мета
> **Дата:** 2026-09-27 · **Тип:** `feature` · **Статус:** ✅ завершено

## Что реализовано

### 17 CLI-утилит через `writeShellApplication`

Все скрипты упакованы в `scripts/default.nix` с явными runtime-зависимостями через `lib.makeBinPath`.

| Утилита | Назначение | Зависимости |
|---|---|---|
| `extract` | Авто-определение формата архива | unzip, unrar, p7zip, tar, zstd, xz, lzma |
| `archive` | Авто-определение формата архива (создание) | zip, tar, zstd, xz, lzma, unrar, p7zip |
| `fileinfo` | Информация о файле (тип, размер, hash, metadata) | file, exiftool |
| `share` | Temporary HTTP server | python3Full |
| `doctor` | Системная диагностика | nix, systemctl, df, free, lspci, pactl |
| `nixcheck` | Nix-обёртка (flake, build, eval, format, gc) | nix, nixpkgs-fmt |
| `make-qr` | Генерация QR-кода | qrencode |
| `clip-ocr` | OCR из clipboard | wl-clipboard, tesseract |
| `tidy-downloads` | Анализ Downloads | fd |
| `img-resize` | Resize изображений | imagemagick |
| `img-compress` | Сжатие изображений | imagemagick, optipng, pngquant, jpegoptim, gifsicle |
| `vid2audio` | Извлечение аудио из видео | ffmpeg_7 |
| `vid2gif` | Конвертация видео в GIF | ffmpeg_7 |
| `pdf2text` | PDF → текст | poppler_utils |
| `batch-rename` | Массовое переименование | — |
| `find-duplicates` | Поиск дубликатов | fdupes |
| `hashfile` | SHA256 хеш файлов | — |

### Старые скрипты (перепакованы)

| Скрипт | Назначение | Зависимости |
|---|---|---|
| `rofi-scripts` | Launcher для media | rofi |
| `wallpaper` | Случайная обой | hyprctl, hyprpaper |
| `rofi-image` | Image convert/resize/crop | rofi, imagemagick, libnotify, fd |
| `rofi-video` | Video convert/resize/crop | rofi, ffmpeg_7, libnotify, fd |
| `rofi-audio` | Audio convert/bitrate/trim | rofi, ffmpeg_7, libnotify, fd |

### Новые пакеты в `tools.nix`

- `poppler_utils` — PDF CLI (pdftotext, pdfinfo, и т.д.)
- `tesseract`, `ocrmypdf` — OCR
- `optipng`, `pngquant`, `jpegoptim`, `gifsicle` — оптимизация изображений
- `pandoc` — конвертация документов
- `rename`, `fdupes` — batch rename, duplicate detection
- `qrencode` — QR generation
- `nh`, `nvd`, `nixpkgs-fmt` — Nix UX
- `python3Full` — для share script
- `file`, `hashid` — file info, hash identification
- `wl-clipboard`, `wl-copy`, `wl-paste` — clipboard
- `unicode`, `color` — unicode/color tools
- `tar`, `zstd`, `xz`, `lzma` — архивы

### Структура

```
scripts/
├── default.nix              # writeShellApplication для всех скриптов
├── media/
│   ├── rofi-image.sh        # существующий скрипт
│   ├── rofi-video.sh        # существующий скрипт
│   └── rofi-audio.sh        # существующий скрипт
├── extract                  # writeShellApplication
├── archive                  # writeShellApplication
├── fileinfo                 # writeShellApplication
├── share                    # writeShellApplication
├── doctor                   # writeShellApplication
├── nixcheck                 # writeShellApplication
├── make-qr                  # writeShellApplication
├── clip-ocr                 # writeShellApplication
├── tidy-downloads           # writeShellApplication
├── img-resize               # writeShellApplication
├── img-compress             # writeShellApplication
├── vid2audio                # writeShellApplication
├── vid2gif                  # writeShellApplication
├── pdf2text                 # writeShellApplication
├── batch-rename             # writeShellApplication
├── find-duplicates          # writeShellApplication
└── hashfile                 # writeShellApplication

home/features/automation/
└── default.nix              # модуль автоматизации (алиасы + пакеты)
```

### Zsh алиасы

Добавлены в `home/features/cli/shell/zsh.nix`:
```bash
ex=extract  ar=archive  fi=fileinfo  sh=share  dc=doctor
nc=nixcheck qr=make-qr  oc=clip-ocr  td=tidy-downloads
ir=img-resize ic=img-compress va=vid2audio vg=vid2gif
pt=pdf2text br=batch-rename fdups=find-duplicates hf=hashfile
```

### Принципы

- Каждая утилита — одна ответственность
- `writeShellApplication` с явными `runtimeInputs`
- Никаких монолитов
- Никаких новых программ без необходимости
- Все зависимости декларативны
- `--help` поддерживается (через bash `set -euo pipefail`)
- Безопасные операции (проверка файлов, dry-run где возможно)

### Коммит

`92e3b08`

---

*Теги:* `#devlog` `#nixos` `#feature`
