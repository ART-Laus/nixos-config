---
title: "Automation Layer — Этап 1: Полный Аудит"
date: 2026-09-27
tags:
  - nixos
  - devlog
  - audit
aliases:
  - "2026-09-27 automation layer audit"
related:
  - "[[devlog]]"
---

# 2026-09-27 — Automation Layer: Этап 1 — Полный Аудит

> [!info] Мета
> **Дата:** 2026-09-27 · **Тип:** `audit` · **Статус:** ✅ завершено

## Цель

Инвентаризация всего существующего в `~/nixos-config` для построения слоя бытовой автоматизации. Каталогизация: что уже есть, что уже умеет, чего не хватает, где дубли.

---

## 1. Карта проекта

### Структура

```
~/nixos-config/
├── flake.nix                    # флейк: nixpkgs 25.05, HM 25.05, Hyprland
├── lib/theme.nix                # toRgba, toRgbaAlpha хелперы
├── theme/
│   ├── colors.nix               # единственный источник цветов (Artlaus Neon)
│   ├── fonts.nix                # UI/mono/nerd/emoji шрифты
│   └── default.nix              # реэкспорт + хелперы
├── scripts/
│   ├── default.nix              # Nix package для rofi-media-scripts
│   ├── wallpaper.sh             # случайная обой
│   ├── rofi-scripts.sh          # rofi launcher для media
│   ├── new-note.nix             # создание заметки
│   └── media/
│       ├── rofi-image.sh        # ImageMagick: convert/resize/crop
│       ├── rofi-video.sh        # ffmpeg: convert/resize/crop
│       └── rofi-audio.sh        # ffmpeg: convert/bitrate/trim
├── home/
│   ├── default.nix              # HM агрегатор
│   ├── gtk-qt.nix               # GTK/Qt тема (adw-gtk3-dark, kvantum)
│   └── features/
│       ├── cli/
│       │   ├── default.nix      # агрегатор CLI
│       │   ├── tools.nix        # 80+ CLI утилит
│       │   ├── shell/zsh.nix    # zsh + OMZ + starship + zoxide + fzf
│       │   ├── shell/starship.nix
│       │   ├── terminal/alacritty.nix
│       │   ├── terminal/kitty.nix
│       │   ├── git.nix
│       │   ├── yazi.nix
│       │   ├── tmux.nix
│       │   ├── neofetch.nix
│       │   └── neovim/          # Lazy.nvim + 18 плагинов
│       ├── desktop/
│       │   ├── default.nix
│       │   ├── apps.nix         # thunar, file-roller, networkmanagerapplet...
│       │   ├── browsers.nix     # firefox
│       │   ├── compositor/hyprland.nix  # 28+ биндингов, Super-key
│       │   ├── compositor/hyprpaper.nix
│       │   ├── bar/waybar.nix   # waybar с now.sh
│       │   ├── bar/scripts/now.sh + default.nix
│       │   ├── launcher/rofi.nix
│       │   ├── lockscreen/swaylock.nix
│       │   ├── notifications/dunst.nix
│       │   ├── wallpapers/     # 122 изображения
│       │   └── orpheus/         # Navidrome + FileBrowser + SMB
│       ├── development/         # LSP, API/DB, диаграммы
│       ├── media/               # vlc, imv, qview, obs, strawberry...
│       └── gaming/              # пусто (system управляет)
├── system/
│   ├── packages.nix             # системные пакеты, шрифты, libs
│   ├── nix.nix                  # GC, substituters, cache
│   ├── services.nix             # greetd, portals, ollama, tor, tailscale
│   ├── virtualization.nix       # Docker + cifs-utils + smbclient
│   ├── networking-security.nix  # NM, firewall, GPG, polkit
│   ├── boot-hardware.nix        # systemd-boot, amdgpu, pipewire, BT
│   └── gaming.nix               # Steam
├── hosts/msi-laptop/
│   ├── default.nix              # единая точка входа
│   └── hardware-configuration.nix
├── docs/devlog/                 # 16 записей
└── about.md                     # полный аудит конфига (493 строки)
```

---

## 2. Инвентаризация инструментов

### 2.1 УЖЕ СУЩЕСТВУЕТ И ПОЛНОСТЬЮ ВЫПОЛНЯЕТ ЗАДАЧУ

| Категория | Инструмент | Где | Что умеет |
|---|---|---|---|
| **Видео** | `ffmpeg_7` | `tools.nix` | convert, trim, extract audio, resize, GIF, frames, merge, metadata |
| **Изображения** | `imagemagick` | `tools.nix` | convert, resize, crop, rotate, compress, format conversion |
| **Изображения** | `vips` | `tools.nix` | быстрая обработка, resize, convert |
| **JSON** | `jq` | `tools.nix` | parse, filter, transform |
| **YAML** | `yq` | `tools.nix` | parse, edit |
| **Терминал графика** | `chafa` | `tools.nix` | image → terminal |
| **Терминал графика** | `timg` | `tools.nix` | image/video → terminal |
| **Терминал графика** | `notcurses` | `tools.nix` | character graphics |
| **Файлы** | `eza` | `tools.nix` | ls с цветом, git, дерево |
| **Файлы** | `bat` | `tools.nix` | cat с синтаксисом |
| **Файлы** | `ripgrep` | `tools.nix` | быстрый grep |
| **Файлы** | `fd` | `tools.nix` | быстрый find |
| **Файлы** | `fzf` | `tools.nix` | fuzzy finder |
| **Файлы** | `zoxide` | `tools.nix` | умный cd |
| **Диск** | `ncdu` | `tools.nix` | анализ диска |
| **Система** | `btop` | `tools.nix` | мониторинг |
| **Git** | `lazygit` | `tools.nix` | TUI git |
| **Git** | `gh` | `tools.nix` | GitHub CLI |
| **Git** | `git-lfs` | `tools.nix` | LFS |
| **Git** | `delta` | `tools.nix` | дифференциал |
| **Архивы** | `zip`, `unzip`, `unrar`, `p7zip`, `bzip2` | `tools.nix` | архивы |
| **Nix** | `nixmate`, `nixard`, `verynix`, `super-comma`, `nixy`, `niux`, `nix-pretty` | `tools.nix` | Nix управление |
| **Безопасность** | `pass`, `pwgen` | `tools.nix` | пароли |
| **Железо** | `lm_sensors`, `usbutils` | `tools.nix` | sensors, USB |
| **Данные** | `miller`, `tree` | `tools.nix` | CSV/JSON processing |
| **Утилиты** | `killall`, `timer` | `tools.nix` | kill, timer |
| **Терминал арт** | `px2ansi-rs`, `vinz`, `anima`, `phosphor`, `milli` | `tools.nix` | ASCII/ANSI |
| **TUI** | `tuitab`, `tooi`, `bitchat-tui`, `puls` | `tools.nix` | TUI инструменты |
| **Nix fun** | `nix-bonsai`, `coretilus` | `tools.nix` | бонсай, coreutils parody |
| **Калькулятор** | `qalculate` | `tools.nix` + `media` | калькулятор |
| **Таск-менеджер** | `planify` | `media` | tasks |
| **Скриншоты** | `ksnip` | `media` | скриншоты |
| **Медиа** | `playerctl` | `media` | media control |
| **Аудио** | `pavucontrol`, `easyeffects` | `media` | audio control |
| **Музыка** | `strawberry` | `media` | music player |
| **Видео** | `vlc` | `media` | video player |
| **Изображения** | `imv`, `qview`, `feh` | `media` | image viewers |
| **Запись** | `obs-studio` | `media` | screen recording |
| **PDF** | `evince` | `media` | PDF viewer |
| **Документы** | `libreoffice`, `calibre` | `media` | office, ebooks |
| **Дизайн** | `krita`, `gimp3`, `gcolor3` | `media` | image editing |
| **Заметки** | `obsidian` | `media` | notes |
| **Торренты** | `qbittorrent` | `media` | torrents |
| **Диаграммы** | `drawio`, `xournalpp`, `hugo` | `development` | diagrams |
| **API/DB** | `dbeaver-bin`, `pgadmin4`, `postman`, `insomnia` | `development` | database/API |
| **Система** | `networkmanagerapplet`, `brightnessctl` | `apps` | system |
| **Клавиатура** | `qmk`, `vial` | `apps` | keyboard |
| **Соцсети** | `discord`, `ayugram-desktop` | `apps` | social |
| **Браузер** | `firefox` | `browsers` | browser |
| **Файловый менеджер** | `thunar`, `catfish`, `exo`, `file-roller` | `apps` | file manager |
| **Файловый менеджер** | `yazi` | `cli` | terminal FM с превью |
| **Терминал** | `alacritty`, `kitty` | `cli` | terminals |
| **Лаунчер** | `rofi` | `desktop` | launcher |
| **Панель** | `waybar` | `desktop` | bar |
| **Уведомления** | `dunst` | `desktop` | notifications |
| **Локскрин** | `swaylock`, `swayidle` | `desktop` | lock screen |
| **Композитор** | `hyprland`, `hyprpaper` | `desktop` | window manager |
| **Редактор** | `neovim` | `cli` | editor с 18 плагинами |
| **Шелл** | `zsh` + OMZ + starship | `cli` | shell |
| **Env** | `direnv` + `nix-direnv` | `cli` | env management |
| **VCS** | `git` | `cli` | version control |
| **Сист. инфа** | `neofetch` | `cli` | system info |
| **Docker** | `docker`, `docker-compose` | `system` | containers |
| **SMB** | `cifs-utils`, `smbclient` | `system` | SMB client |
| **Project Orpheus** | `orpheus` CLI, Navidrome, FileBrowser | `orpheus/` | music server |
| **Скрипты** | `wallpaper.sh`, `rofi-scripts.sh`, `rofi-{image,video,audio}.sh`, `new-note.nix` | `scripts/` | automation |
| **Тема** | `theme/colors.nix`, `theme/fonts.nix`, `theme/default.nix` | `theme/` | единая палитра |
| **GTK/Qt** | `adw-gtk3-dark`, `kvantum`, `qt6ct`, `qt5ct` | `gtk-qt.nix` | тема |

### 2.2 ЧАСТИЧНО СУЩЕСТВУЕТ (нужна оболочка / доработка)

| Категория | Что есть | Что не хватает |
|---|---|---|
| **PDF** | `evince` (просмотр), `poppler` (libs) | `pdftotext`, `pdfinfo`, `pdfseparate`, `pdfunite`, `pdftoppm` — утилиты CLI |
| **OCR** | нет | `tesseract`, `ocrmypdf` |
| **Изображения** | `imagemagick`, `vips` | `optipng`, `pngquant`, `jpegoptim`, `gifsicle` (оптимизация) |
| **Музыка** | `strawberry`, `playerctl`, `easyeffects` | `ffmpeg` (уже есть) для конвертации, но нет batch-инструментов |
| **Clipboard** | `wl-clipboard`, `cliphist` (в hyprland) | нет `xclip`/`xsel` для X11, нет `wl-copy` в алиасах |
| **QR** | нет | `qrencode` |
| **Downloads** | нет | нет `tidy-downloads` аналога |
| **Nix** | `nixmate`, `nixard`, `verynix`, `nixy`, `niux`, `nix-pretty` | нет `nh`, `nvd`, `nixfmt` (есть `nixpkgs-fmt` в development) |
| **Doctor** | нет | нет `doctor`/`system-report` скриптов |
| **Archive** | `zip`, `unzip`, `unrar`, `p7zip`, `bzip2` | нет `tar`, `zstd`, `xz`, `lzma` CLI (есть в system) |
| **Share** | нет | нет `python3 -m http.server` обёртки, нет `qrencode` |
| **Unicode** | нет | нет `unicode` инструментов |
| **Color** | нет | нет `color` конвертации |
| **Text** | `jq`, `yq`, `miller` | нет `pandoc` (документы) |
| **Hash** | нет | нет `sha256sum` в алиасах (есть в system) |
| **Duplicate** | нет | нет `fdupes`, `rdfind` |
| **Rename** | нет | нет `rename`, `mmv` |
| **File type** | нет | нет `file` в алиасах (есть в system) |

### 2.3 НЕ СУЩЕСТВУЕТ (нужно добавить)

| Категория | Инструмент | Зачем |
|---|---|---|
| **PDF** | `poppler_utils` | pdftotext, pdfinfo, pdfseparate, pdfunite |
| **OCR** | `tesseract`, `ocrmypdf` | OCR |
| **Оптимизация** | `optipng`, `pngquant`, `jpegoptim`, `gifsicle` | image optimization |
| **QR** | `qrencode` | QR generation |
| **Дубликаты** | `fdupes` | duplicate detection |
| **Переименование** | `rename` (perl-rename) | batch rename |
| **Документы** | `pandoc` | document conversion |
| **Nix UX** | `nh`, `nvd` | nix package management |
| **Системная диагностика** | (скрипты) | `doctor`, `system-report` |
| **Share** | (скрипты) | temporary HTTP server |
| **Downloads** | (скрипты) | tidy-downloads |
| **Clipboard** | `wl-clipboard` в алиасах | clipboard history |
| **Unicode** | `unicode` | unicode inspection |
| **Color** | `color` | color conversion |
| **Tar** | `tar`, `zstd`, `xz`, `lzma` | архивы (частично есть) |
| **File info** | `file` | MIME/type detection |
| **Hash** | `sha256sum`, `md5sum` | hash |

---

## 3. Существующие скрипты и их покрытие

| Скрипт | Что делает | Что НЕ делает |
|---|---|---|
| `rofi-image.sh` | convert, resize, crop через rofi + IM | нет compress, optimize, batch, metadata |
| `rofi-video.sh` | convert, resize, crop через rofi + ffmpeg | нет GIF, frames, trim, metadata, merge |
| `rofi-audio.sh` | convert, bitrate, trim через rofi + ffmpeg | нет normalize, split, join, CUE, metadata |
| `wallpaper.sh` | случайная обой из wallpapers/ | нет resize, optimize |
| `rofi-scripts.sh` | launcher для media scripts | — |
| `new-note.nix` | создаёт заметку в ALN | — |
| `now.sh` | Last.fm now playing для waybar | сломан (placeholders) |
| `wallpaper.sh` (Hyprland) | hyprpaper wallpaper | — |

---

## 4. Существующие алиасы и функции

### Zsh aliases (`zsh.nix`)

```bash
ll, la, l          # ls
vi = nvim
y = yazi
g, lg = lazygit
d = delta
gs, ga, gc, gp     # git
top, bt, htop = btop
jq, jj             # jq
h, http            # http
cd = z             # zoxide
rg, rgg            # ripgrep
cle = clear
.., ...            # cd
aln                # cd ~/Documents/ALN && nvim
nn                 # new_note (сломан)
rbs, rbb, upg, upd # nixos-rebuild
grb                # nix-collect-garbage
pkgs               # nvim packages.nix
t = timer
```

### Hyprland keybinds (`hyprland.nix`)

```
Super+Enter → Terminal
Super+B → Browser
Super+T → Ayugram
Super+E → Files
Super+W → Wallpaper
Super+Q → killactive
Super+Shift+F → fullscreen
Super+G → resize
Super+H → btop
Super+N → planify
Super+K → qalculate
Super+Y → yazi
Super+P → ksnip
Super+L → swaylock
Super+R → rofi-scripts
Super+V → cliphist
Print → screenshot
```

---

## 5. Дубли и конфликты

| Дубли | Детали |
|---|---|
| `htop` + `btop` | `btop` в system + алиасах, `htop` в system — `btop` достаточно |
| `neofetch` | Только в `cli/neofetch.nix`, один |
| `jq` | В `tools.nix` + алиас `jj=jq` — тавтология |
| `ffmpeg` | В `tools.nix` + `media/default.nix` — дублирование пакета |
| `imagemagick` | В `tools.nix` + `rofi-image.sh` зависит |
| `vips` | В `tools.nix`, не используется в скриптах |
| `poppler` | В `system/packages.nix` (libs), нет CLI утилит |
| `tar` архиваторы | `zip/unzip/unrar/p7zip/bzip2` в tools, `tar/zstd/xz` в system — разрозненно |
| `qt6ct` + `qt5ct` | Конфликт в `hyprland.nix` vs `gtk-qt.nix` |
| `polkit` | Двойной запуск (systemd + exec-once) |
| `alacritty` | В `terminal/alacritty.nix` + `hyprland.nix` bind `Return` |
| `rofi` | В `launcher/rofi.nix` + `scripts/rofi-scripts.sh` |
| `wallpaper` | `wallpaper.sh` + `hyprpaper` + `rofi-scripts` |

---

## 6. Что уже возможно без новых пакетов

### Файлы
- **inspect**: `eza`, `bat`, `fd`, `ripgrep`, `file` (system)
- **hash**: `sha256sum`, `md5sum` (system)
- **MIME**: `file` (system)
- **archive**: `zip`, `unzip`, `unrar`, `p7zip`, `bzip2`, `tar`, `zstd`, `xz` (system)
- **rename**: нет batch rename
- **duplicate**: нет
- **cleanup**: `rm`, `trash` (нет)

### Изображения
- **convert**: `imagemagick` (convert, mogrify)
- **resize**: `imagemagick`, `vips`
- **crop**: `imagemagick`
- **rotate**: `imagemagick`
- **compress**: нет оптимизации (нет optipng/pngquant/jpegoptim)
- **format**: `imagemagick`
- **thumbnail**: `ffmpegthumbnailer` (system), `vips`
- **ASCII**: `chafa`, `px2ansi-rs`, `timg`, `notcurses`
- **metadata**: `exiftool` (через yazi reveal, не как отдельный инструмент)

### Видео
- **convert**: `ffmpeg_7`
- **resize**: `ffmpeg_7`
- **crop**: `ffmpeg_7`
- **trim**: `ffmpeg_7`
- **extract audio**: `ffmpeg_7`
- **GIF**: `ffmpeg_7`
- **frames**: `ffmpeg_7`
- **merge**: `ffmpeg_7`
- **metadata**: `ffmpeg_7`
- **thumbnail**: `ffmpegthumbnailer` (system)

### Аудио
- **convert**: `ffmpeg_7`
- **bitrate**: `ffmpeg_7`
- **trim**: `ffmpeg_7`
- **normalize**: нет
- **split/join**: нет
- **CUE**: нет
- **metadata**: `ffmpeg_7`, `exiftool`
- **loudness**: нет

### PDF
- **view**: `evince`
- **convert**: нет (`pandoc` нет)
- **merge/split**: нет (`pdfunite`, `pdfseparate` нет)
- **compress**: нет
- **text**: нет (`pdftotext` нет)
- **OCR**: нет

### Clipboard
- **history**: `cliphist` (Hyprland bind)
- **copy/paste**: `wl-copy`, `wl-paste` (system)
- **image → OCR**: нет
- **text transform**: нет
- **JSON format**: `jq`
- **Base64**: нет
- **QR**: нет

### Архивы
- **extract**: `zip`, `unzip`, `unrar`, `p7zip`, `bzip2`, `tar`, `zstd`, `xz`
- **create**: `zip`, `tar`, `zstd`, `xz`
- **auto-detect**: нет удобной оболочки

### Система
- **disk**: `ncdu`, `df`, `du`
- **process**: `btop`, `htop`
- **memory**: `btop`, `free`
- **network**: `mtr`, `dog`, `nmcli`
- **Nix**: `nixmate`, `nixard`, `verynix`, `nixy`, `niux`, `nix-pretty`, `nixpkgs-fmt`
- **doctor**: нет
- **report**: нет

### Nix
- **format**: `nixpkgs-fmt`, `nix-pretty`
- **check**: `nix flake check`
- **build**: `nix build`
- **switch**: `nixos-rebuild`
- **generations**: `nixos-rebuild list`
- **rollback**: `nixos-rebuild switch`
- **gc**: `nix-collect-garbage`
- **search**: `nix search`
- **deps**: `nix-store --query`

### Терминал
- **color**: нет
- **Unicode**: нет
- **Base64**: нет
- **hex**: нет
- **slugify**: нет
- **text transform**: нет
- **ANSI**: `chafa`, `px2ansi-rs`
- **visualization**: `timg`, `notcurses`, `chafa`

---

## 7. Потенциальные обёртки (wrapper) вместо новых пакетов

| Задача | Существующий инструмент | Обёртка |
|---|---|---|
| Archive extract | `zip`, `unzip`, `p7zip`, `tar`, `zstd`, `xz` | `extract` скрипт с auto-detect |
| Archive create | `zip`, `tar`, `zstd`, `xz` | `archive` скрипт с auto-detect |
| Image resize | `imagemagick` | `img-resize` скрипт |
| Image compress | `imagemagick` + `optipng`/`pngquant` | `img-compress` скрипт |
| Video to audio | `ffmpeg` | `vid2audio` скрипт |
| Video to GIF | `ffmpeg` | `vid2gif` скрипт |
| PDF to text | `poppler_utils` | `pdf2text` скрипт |
| File info | `file`, `exiftool` | `fileinfo` скрипт |
| Hash | `sha256sum` | `hashfile` скрипт |
| Duplicate find | `fdupes` | `find-duplicates` скрипт |
| Batch rename | `rename` | `batch-rename` скрипт |
| Temporary share | `python3 -m http.server` | `share` скрипт |
| QR code | `qrencode` | `make-qr` скрипт |
| System doctor | `systemctl`, `nix`, `df`, `free` | `doctor` скрипт |
| Nix check | `nix flake check`, `nix build` | `nixcheck` скрипт |
| Downloads tidy | `fd`, `file`, `mv` | `tidy-downloads` скрипт |
| Clipboard OCR | `wl-paste`, `tesseract` | `clip-ocr` скрипт |
| Color convert | `color` CLI | `colorconvert` скрипт |
| Unicode inspect | `unicode` | `unicode-info` скрипт |

---

## 8. Проблемы текущего скриптового стека

1. **`rofi-image.sh`, `rofi-video.sh`, `rofi-audio.sh`** — монолитные, 100+ строк каждый, используют `fd . ~ -t f` что медленно для больших директорий
2. **`now.sh`** — сломан (placeholders), не используется
3. **`wallpaper.sh`** — хардкод пути (исправлен)
4. **Нет единого `toolbox`** — нет универсальной точки входа
5. **Нет `extract`/`archive`** — нет auto-detect оболочки
6. **Нет `doctor`/`system-report`** — нет диагностики
7. **Нет `share`** — нет temporary HTTP server
8. **Нет `tidy-downloads`** — нет категоризации downloads

---

## 9. Что уже работает из Discovery Expansion

Из `tools.nix` (24 инструмента):
- `px2ansi-rs`, `vinz`, `anima`, `timg`, `notcurses`, `tuitab`, `tooi`, `bitchat-tui`, `puls`, `nixmate`, `nixard`, `verynix`, `super-comma`, `nixy`, `niux`, `nix-pretty`, `coretilus`, `nix-bonsai`, `phosphor`, `milli`, `chafa`, `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `zoxide`, `btop`, `jq`, `yq`, `ncdu`, `dog`, `mtr`, `entr`, `tldr`, `zip`, `unzip`, `unrar`, `p7zip`, `bzip2`, `ffmpeg_7`, `imagemagick`, `vips`, `lazygit`, `gh`, `git-lfs`, `delta`, `pass`, `pwgen`, `lm_sensors`, `usbutils`, `miller`, `tree`, `killall`, `timer`

---

## 10. Выводы

### Tier A — Практически наверняка полезно каждый день
1. `extract` / `archive` — auto-detect archive wrapper
2. `img-resize` / `img-compress` — image processing wrapper
3. `vid2audio` / `vid2gif` — video processing wrapper
4. `fileinfo` — file inspection wrapper
5. `share` — temporary HTTP server
6. `doctor` — system diagnostics
7. `nixcheck` — Nix wrapper
8. `make-qr` — QR generation
9. `clip-ocr` — clipboard OCR
10. `tidy-downloads` — downloads organizer

### Tier B — Полезно несколько раз в неделю
1. `batch-rename` — batch rename
2. `find-duplicates` — duplicate detection
3. `pdf2text` / `pdf-merge` / `pdf-split` — PDF tools
4. `hashfile` — file hash
5. `colorconvert` — color conversion
6. `unicode-info` — unicode inspection
7. `normalize-audio` — audio normalization
8. `optimize-images` — batch image optimization

### Tier C — Редко, но очень удобно
1. `cue-split` — CUE splitting
2. `contact-sheet` — video contact sheet
3. `favicon-gen` — favicon generation
4. `slugify` — text slugification
5. `base64-encode` / `base64-decode` — base64
6. `url-encode` / `url-decode` — URL encoding
7. `hex-dump` — hex inspection
8. `ansi-preview` — ANSI preview

### Tier D — Экспериментальные / fun
1. `coretilus` — уже есть
2. `nix-bonsai` — уже есть
3. `ascii-art` — из `chafa`/`px2ansi-rs`
4. `terminal-screenshot` — `timg` + `grim`
5. `system-visualization` — `puls` / `btop`

---

## 11. Следующий шаг

**Этап 3 — Interview**: задать вопросы о реальных pain points перед тем, как строить обёртки.

Не начинать реализацию без понимания, какие операции пользователь действительно выполняет через браузер/GUI/вручную.

---

*Теги:* `#devlog` `#nixos` `#audit`
