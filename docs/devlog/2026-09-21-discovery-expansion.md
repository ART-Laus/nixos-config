# NixOS Discovery Expansion — Каталог Находок

*Дата: 2026-09-21. Фаза: Только исследование — ничего не установлено.*

---

## Сводка Инвентаря (Чёрный Список)

Прежде чем представить находки, вот полный софт-инвентарь, который служит чёрным списком:

**Явно установленные CLI-инструменты:** eza, bat, ripgrep, fd, fzf, zoxide, btop, jq, yq, ncdu, dog, mtr, entr, tldr, chafa, zip, unzip, unrar, p7zip, bzip2, ffmpeg_7, imagemagick, vips, lazygit, gh, git-lfs, delta, pass, pwgen, lm_sensors, usbutils, miller, tree, killall, timer, neofetch

**Shell/Terminal:** zsh, oh-my-zsh, zsh-autosuggestions, zsh-completions, fast-syntax-highlighting, zsh-autopair, zsh-you-should-use, starship, alacritty, kitty, tmux, yazi

**Development:** python3Full, pyright, ruff, nixd, nixpkgs-fmt, lua-language-server, stylua, rust-analyzer, gopls, golangci-lint, typescript-language-server, tailwindcss-language-server, vscode-langservers-extracted, bash-language-server, shellcheck, shfmt, dbeaver-bin, pgadmin4, postman, insomnia, drawio, xournalpp, hugo

**Media:** vlc, imv, qview, feh, ffmpeg_7, obs-studio, pavucontrol, playerctl, strawberry, easyeffects, evince, libreoffice, calibre, hunspell, krita, gimp3, gcolor3, obsidian, planify, ksnip, screenkey, qbittorrent

**Desktop:** xfce.thunar, xfce.catfish, xfce.exo, file-roller, ffmpegthumbnailer, gnome-epub-thumbnailer, f3d, openscad, networkmanagerapplet, brightnessctl, qmk, vial, discord, ayugram-desktop, firefox

**GTK/Qt:** adw-gtk3, papirus-icon-theme, bibata-cursors, nerd-fonts.jetbrains-mono, qt5ct, qt6ct, kvantum

**System:** git, curl, wget, htop, tor, openvpn, tailscale, docker, docker-compose, pciutils, usbutils, lm_sensors, libva-utils, clinfo, alsa-utils, pamixer, papirus-icon-theme, breeze-icons, различные библиотеки, шрифты (noto, nerd-fonts, carlito, terminus, inconsolata, font-awesome, liberation, dejavu, cantarell, unifont)

**Services:** greetd, tuigreet, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk, thunar, polkit_gnome, ollama, nix-ld, appimage-run, tor, openvpn, tailscale

**Gaming:** steam

**Neovim плагины (lazy.nvim):** telescope, nvim-tree, bufferline, lualine, cmp, noice, treesitter, alpha, autopairs, comment, colorizer, formatting-linting, langmapper, lspsaga, markdown, telescope, treesitter, yazi.nvim, lazy-nvim

---

## 🎨 Визуал / ASCII / Терминальная Графика

### 1. px2ansi-rs

**Что это:** Рендерер терминальных изображений высокого разрешения и менеджер ассетов. Преобразует изображения в терминальное искусство с помощью 10 стилей рендеринга.

**Что умеет:**
- 10 стилей рендеринга: `ansi`, `unicode`, `fade`, `ascii`, `braille`, `full-block`, `dense`, `chinese`, `kanji`, `sixel`
- Fuzzy search + интерактивный TUI-браузер для библиотек спрайтов
- Truecolor + прозрачность через цветовое пространство Oklab
- 5 фильров масштабирования (nearest → lanczos3)
- Управление плотностью ASCII, монохромный вывод, дITHERинг Флойда-Штейнберга
- Поворот изображений, режим fetch (информация о системе + вращающиеся изображения)
- Растеризация PNG (ANSI → PNG)
- SIMD-обработка пикселей через авто-векторизацию LLVM

**Почему интересно:** Это самый полный рендерер терминальных изображений, который я нашёл. Он значительно превосходит возможности chafa благодаря 10 различным стилям рендеринга, интерактивному TUI-браузеру и fuzzy search. Стили braille и kanji производят впечатляюще детализированный вывод.

**Что уже есть:** chafa (установлен) — выполняет базовый ANSI/Unicode/Sixel рендеринг. px2ansi-rs предлагает принципиально больше стилей и интерактивный TUI-браузер, которого у chafa нет.

**Отличие от chafa:** chafa — это рендерер; px2ansi-rs — рендерер + менеджер ассетов + TUI-браузер с 10 различными алгоритмами против нескольких у chafa.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install px2ansi-rs` или GitHub release. На базе Rust.

**Open Source:** Да (MIT/Apache-2.0)

**Зрелость:** Активная разработка, свежие релизы

**Рекомендация:** ВЫСОКАЯ — уникальная возможность, не дублирует chafa

---

### 2. phosphor

**Что это:** Рендеринг изображений, PDF и markdown в терминале. Поддерживает Kitty graphics protocol с Unicode-виртуальным размещением, Sixel, iTerm2 и halfblock-фоллбэк — с полным tmux passthrough.

**Что умеет:**
- Авто-детекция лучшего протокола для терминала (Kitty > iTerm2 > Sixel > Halfblock)
- Поддержка PNG, JPEG, WebP, GIF, AVIF, TIFF, SVG, BMP, HEIC, PDF, Markdown
- Работает внутри tmux через виртуальное Unicode-размещение + DCS passthrough
- TypeScript библиотека + CLI
- Программный API для встраивания

**Почему интересно:** phosphor элегантно решает проблему рендеринга изображений внутри tmux. Работает внутри tmux (что chafa делает плохо) и авто-детектирует лучший протокол. Поддержка PDF и Markdown уникальна.

**Что уже есть:** chafa (установлен), imv/qview (просмотрщики изображений), но ни один не работает внутри tmux с авто-детекцией протокола.

**Отличие от chafa:** phosphor работает внутри tmux, поддерживает PDF/Markdown, авто-детектирует протоколы. chafa — автономный и не обрабатывает tmux passthrough.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `npm install -g phosphor` или GitHub release.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** ВЫСОКАЯ — решает рендеринг в tmux, уникальная авто-детекция протоколов

---

### 3. fidelitty

**Что это:** Библиотека для высокоразрешённой интегрированной терминальной графики. Рендерит изображения с помощью кастомного битмап-шрифта с кодовыми точками Private Use Area.

**Что умеет:**
- 2×4 или 3×5 пиксельное разрешение на клетку терминала
- Кастомный шрифт генерируется в рантайме (нет конфликтов с существующими шрифтами)
- >120fps при низком разрешении
- Работает поверх SSH
- Двойная функция как сжатие изображений
- Zig библиотека + C заголовок

**Почему интересно:** Это принципиально другой подход к терминальному рендерингу изображений — использование кастомных шрифтов в Private Use Area вместо ANSI escape-последовательностей. Это значит, что работает на ЛЮБОМ терминале, поддерживающем Unicode, даже без truecolor или graphics protocols.

**Что уже есть:** chafa (на базе ANSI), phosphor (на базе протоколов). fidelitty использует совершенно другой механизм.

**Отличие:** fidelitty работает на терминалах без truecolor/graphics поддержки через кастомные Unicode-шрифты. Другие требуют специфичных терминальных возможностей.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install fidelitty` или Zig build.

**Open Source:** Да

**Зрелость:** Исследовательская/экспериментальная стадия

**Рекомендация:** СРЕДНЯЯ — новаторский подход, но экспериментально, нишевая задача

---

### 4. ratty

**Что это:** GPU-рендеренный терминальный эмулятор с inline 3D-графикой. Вдохновлён TempleOS. Построен на Rust & Ratatui + Bevy.

**Что умеет:**
- Inline 3D-объекты в терминальном пространстве (`.obj`, `.glb`, `.stl`)
- GPU-рендеринг текста через Bevy/Vello
- Ratty Graphics Protocol (RGP) для 3D-размещения
- Управление камерой: плоская, ортографическая, перспективная, Mobius
- Вращающийся курсор крысы (кастомизируемый)
- Терминальные приложения, построенные вокруг RGP: Ratscad (CAD), ComChan (serial monitor с 3D-телеметрией)

**Почему интересно:** Это первый терминальный эмулятор, который рендерит настоящую 3D-графику inline. Это не замена терминального эмулятора — это НОВАЯ КАТЕГОРИЯ терминала, поддерживающая 3D-контент. Ratty Graphics Protocol может стать стандартом.

**Что уже есть:** Ничего сопоставимого. Это совершенно новая категория.

**Отличие:** Нет существующего инструмента, который рендерит 3D-объекты inline в терминале. Это определяет категорию.

**Установлен:** НЕТ

**NixOS:** Доступен через `nix run github:orhun/ratty` (flake). НЕТ в стабильном nixpkgs. Требует GPU + Bevy/wgpu поддержку.

**Open Source:** Да (MIT)

**Зрелость:** Pre-release/preview. Активная разработка.

**Рекомендация:** ВЫСОКАЯ — совершенно новая категория, «wow»-фактор максимален

---

### 5. milli

**Что это:** Движок пиксельно-точного анимированного ASCII-art. Рендерит изображения и GIF в терминал, или экспортирует в Go/Lua/JSON для встраивания в TUI и Neovim дашборды.

**Что умеет:**
- Рендеринг изображений, GIF, видеокадров в терминал
- Формат `.milli` для мгновенного воспроизведения
- Экспорт в Go/Lua/JSON для встраивания
- Текстовые эффекты (fire, glitch, wave, matrix, dissolve, typewriter, pulse, rainbow)
- Процедурные шейдеры (plasma, rain, doomfire, starfield, tunnel, waves)
- Интеграция с Neovim плагином дашборда
- Truecolor glyph matching

**Почему интересно:** milli мостит разрыв между терминальным рендерингом и встраиванием в приложения. Формат `.milli` и возможности экспорта делают его полезным для создания анимированных splash screens, дашбордов и MOTD-анимаций. Интеграция с Neovim особенно ценна.

**Что уже есть:** chafa (статический рендеринг изображений). milli добавляет анимацию, процедурную генерацию и встраивание.

**Отличие:** milli делает анимацию и процедурную генерацию; chafa делает статический рендеринг. milli экспортирует во встраиваемые форматы.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `npm install -g @amansingh-afk/milli`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** ВЫСОКАЯ — анимация + встраивание + Neovim интеграция

---

### 6. vinz

**Что это:** 3D raymarching, процедурный графический движок для терминала. Математические жидкостные симуляции и ASCII-art с использованием 24-битных ANSI-цветов.

**Что умеет:**
- 10 2D-визуальных стилей + 8 3D raymarching стилей
- 20 цветовых палитр
- True color (24-bit RGB)
- Интерактивный UI с управлением в реальном времени
- Процедурный randomizer (нажми R для нового шейдера)
- Написан на C, однобуферный вывод для высокого FPS
- 3D векторная математика и raymarching движок с нуля

**Почему интересно:** Чистый процедурный терминальный арт с real-time 3D raymarching. Это категория «терминальные скринсейверы» доведённая до логического предела. Интерактивный UI и real-time генерация шейдеров уникальны.

**Что уже есть:** Ничего сопоставимого. Нет процедурного терминального арт-движка.

**Отличие:** Чистый процедурный 3D raymarching в терминале. Никакой другой инструмент этого не делает.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install vinz` или GitHub release.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — чистый toy/визуальный эффект, но впечатляющий

---

### 7. anima (yzs)

**Что это:** Независимый набор инструментов для терминальных анимаций от Yazelix. Boids, friends and enemies, Mandelbrot, Matrix rain, Game of Life, asciiquarium.

**Что умеет:**
- 12+ анимационных стилей (boids, matrix, mandelbrot, game of life, friends_and_enemies, primordial, random, static, logo, asciiquarium)
- Бинарник `yzs` с интерактивным и таймерным воспроизведением
- Kitty PNG frame sequence rendering
- Работает в любом способном терминале
- Nix flake доступен

**Почему интересно:** Чистый Nix-flakeable набор терминальных анимаций. Asciiquarium и boids-симуляции — классический терминальный арт. Nix-интеграция чистая.

**Что уже есть:** Ничего сопоставимого. Нет набора терминальных анимаций.

**Отличие:** Специализированный набор терминальных анимаций с несколькими типами симуляций.

**Установлен:** НЕТ

**NixOS:** Доступен через `nix run github:Yazelix/anima#yzs`. НЕТ в стабильном nixpkgs.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — весело, визуально, Nix-native

---

## 🖼 Изображения / Медиа CLI

### 8. timg

**Что это:** Терминальный просмотрщик изображений и видео. Рендерит медиа через терминальные графические протоколы или Unicode/block-character фоллбэки.

**Что умеет:**
- Sixel, Kitty, iTerm2 graphics protocols для полноформатного отображения
- 24-bit color + Unicode block фоллбэки
- Просмотр изображений, GIF и видео
- Grid display, threaded loading
- Поддержка PDF, SVG, WebP

**Почему интересно:** timg — самый зрелый терминальный просмотрщик изображений/видео. Существует с 2016 года, активно поддерживается и поддерживает самый широкий диапазон протоколов и форматов.

**Что уже есть:** chafa (установлен), imv/qview (GUI просмотрщики). timg специально разработан для terminal-first просмотра с детекцией протоколов.

**Отличие:** timg — специализированный терминальный просмотрщик с авто-детекцией протоколов и поддержкой видео. chafa — скорее рендерер. timg обрабатывает видео воспроизведение.

**Установлен:** НЕТ (chafa установлен, но служит другой цели)

**NixOS:** В nixpkgs (`pkgs.timg`). Проверено.

**Open Source:** Да (GPL-2.0)

**Зрелость:** Очень зрелый (v1.6.3, 2025)

**Рекомендация:** ВЫСОКАЯ — в nixpkgs, зрелый, дополняет chafa видео поддержкой

---

### 9. viu

**Что это:** Простой терминальный просмотрщик изображений на Rust. Использует терминальные графические протоколы когда доступны, фоллбэк на character-cell рендеринг.

**Что умеет:**
- Поддержка iTerm и Kitty graphics protocols
- Block rendering фоллбэк
- Просмотр изображений, GIF, input stream
- Лёгкий, быстрый
- Библиотека `viuer` для встраивания

**Почему интересно:** viu — минималистичная альтернатива timg. Экстремально лёгкий, сфокусирован на одной вещи: показ изображений в терминале.

**Что уже есть:** chafa (установлен). viu проще и более сфокусирован.

**Отличие:** viu проще и легче chafa, с более чистой поддержкой протоколов. Но chafa уже установлен.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (`pkgs.viu`). Проверено.

**Open Source:** Да

**Зрелость:** Стабильный

**Рекомендация:** НИЗКАЯ — chafa уже покрывает эту категорию. viu хорош, но избыточен.

---

### 10. notcurses (и встроенные инструменты)

**Что это:** Блестящая библиотека character graphics/TUI. Не замена ncurses — нацелена на Unicode, 24-bit color, multimedia, terminal bitmap graphics.

**Что делает (встроенные инструменты):**
- `ncls` — multimedia-aware listings каталогов
- `ncneofetch` — клон neofetch используя notcurses
- `ncplayer` — рендеринг визуальных медиа
- `nctetris` — тетрис в терминале
- `notcurses-demo` — демо возможностей
- `notcurses-info` — диагностика терминала
- `notcurses-input` — декодирование нажатий клавиш
- `tfman` — терминальный файловый менеджер

**Почему интересно:** notcurses — это базовая библиотека, питающая многие современные терминальные инструменты. Одни только встроенные инструменты стоят установки. `ncls` (multimedia directory listing) и `ncplayer` — уникальные возможности.

**Что уже есть:** chafa (рендеринг изображений), btop (системный монитор). notcurses предоставляет другой движок рендеринга и встроенные инструменты.

**Отличие:** notcurses — это библиотека + встроенный набор инструментов. `ncls` и `ncplayer` не имеют аналогов в текущем стеке.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (`pkgs.notcurses`). Проверено.

**Open Source:** Да (Apache-2.0)

**Зрелость:** Очень зрелая (v3.0.17)

**Рекомендация:** ВЫСОКАЯ — в nixpkgs, библиотека + встроенные инструменты, `ncls` уникален

---

### 11. dither

**Что это:** Изображение на входе, терминальный splash-скрипт на выходе — truecolor Unicode quadrant-block art, рендеренный dependency-free bash.

**Что умеет:**
- Рендеринг truecolor Unicode quadrant-block art
- Авто-подгонка под терминал вызывающей программы
- Stdlib bash в рантайме (нет зависимостей кроме bash 4+ и stty)
- Генерация `show.sh` скриптов из изображений
- Детерминированный пайплайн

**Почему интересно:** Dependency-free bash подход уникален. Можно сгенерировать самодостаточный `show.sh` из любого изображения и распространять его. Нет Python, нет Rust, нет Cairo — только bash.

**Что уже есть:** chafa (установлен), imagemagick (установлен). bash-only подход dither отличается.

**Отличие:** Чистый bash, генерирует автономные скрипты. Нет рантайм-зависимостей.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `git clone` + `make`.

**Open Source:** Да

**Зрелость:** Ранняя (v0.1.0, 2026-08)

**Рекомендация:** СРЕДНЯЯ — новаторский bash-only подход, но ранняя стадия

---

## 🖥 TUI

### 12. zy

**Что это:** Молниеносно быстрый, безопасный shell. 530+ встроенных команд. 102 модуля prompt. 39 тем. Встроенный fuzzy picker, файловый менеджер, jumper, структурированные пайплайны. Один бинарник, Pure C.

**Что умеет:**
- 533 встроенные команды (гарантируются тестами)
- Встроенный файловый менеджер (`explore`) с трёхпанельными Miller columns
- Встроенный jumper по каталогам (`zi`) с frecency
- Встроенный fuzzy picker (`fzf` builtin)
- 100+ модулей prompt (языки, cloud, git, system)
- 39 тем с OSC sequence переключением палитры терминала
- 17 value types, 60+ filter/transform команд
- Поддержка JSON, CSV, TSV, TOML, YAML, XML, HTML, Markdown, NUON
- Preview изображений через sixel/kitty graphics (при наличии chafa/poppler/ffmpeg)
- ~205,000 строк C, один `.deb`

**Почему интересно:** zy — это полная замена shell, интегрирующая всё в один бинарник. Встроенный файловый менеджер, fuzzy picker и prompt модули устраняют необходимость в отдельных инструментах. Спроектирован для работы С существующими инструментами (zoxide, fzf), но также их заменяет.

**Что уже есть:** zsh + oh-my-zsh + starship + zoxide + fzf + alacritty + yazi. zy заменил бы ВСЁ это одним бинарником.

**Отличие:** zy — это целая экосистема shell в одном бинарнике. Но замена текущего стека выходит за рамки этой фазы.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `.deb` или исходный код. Pure C.

**Open Source:** Да

**Зрелость:** Активная разработка, ~205K LOC

**Рекомендация:** СРЕДНЯЯ — впечатляющий, но заменил бы весь shell стек. Не в рамках discovery expansion.

---

### 13. lazyide

**Что это:** Полный IDE в терминале (написан на Rust). Спроектирован для SSH-сессий и удалённой разработки.

**Что умеет:**
- File tree, tabbed editing, split panes
- LSP интеграция с inline ghost text и диагностикой
- Syntax highlighting для Rust, Python, JS/TS, Go и более
- Code folding, bracket pair colorization
- Git gutter + side-by-side diff
- Minimap, project search, темы, перемаппинг клавиш
- 32 темы с live preview
- Command palette (`Ctrl+P`) и fuzzy quick open (`Ctrl+O`)
- Autosave + crash recovery
- Agent Client Protocol (ACP) интеграция

**Почему интересно:** Это терминальный IDE, который парится с agentic coding инструментами. Спроектирован для SSH-воркфлоу где иначе использовался бы полный GUI IDE. ACP интеграция означает что AI агенты могут им управлять.

**Что уже есть:** Neovim с lazy.nvim + LSP. lazyide — другой подход — больше IDE-like, меньше modal-editor-like.

**Отличие:** lazyide — это IDE (не modal editor), спроектированный для SSH/remote работы с AI agent интеграцией. Neovim — modal editor.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install --git https://github.com/TysonLabs/lazyide` или `nix run`.

**Open Source:** Да (MIT)

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — интересный, но Neovim уже покрывает задачу редактирования

---

### 14. hunk

**Что это:** Review-first терминальный diff viewer для agent-авторизованных changesets. Построен на OpenTUI и Pierre diffs.

**Что умеет:**
- Multi-file review stream с sidebar навигацией
- Inline AI и agent annotations рядом с кодом
- Split, stack, и responsive auto layouts
- Watch mode для авто-перезагрузки file и Git-backed reviews
- Mouse, pager, и Git difftool поддержка
- Jujutsu и Sapling поддержка
- TypeScript extensions система
- Компонент `HunkDiffView` для встраивания в OpenTUI приложения

**Почему интересно:** hunk спроектирован специально для review AI-сгенерированных кодовых изменений. Inline AI annotations и multi-file review stream уникальны. Это не просто diff viewer — это review workflow инструмент.

**Что уже есть:** delta (установлен, предоставляет syntax-highlighted diffs). lazygit (установлен, предоставляет Git TUI). hunk добавляет AI annotations и review-first workflow.

**Отличие:** hunk добавляет AI/agent annotations и review-first UI. delta — diff pager. lazygit — Git TUI. hunk — review инструмент.

**Установлен:** НЕТ

**NixOS:** Есть `flake.nix` но НЕТ в стабильном nixpkgs. Доступен через `nix run github:hunkdiff/hunk`.

**Open Source:** Да

**Зрелость:** Активная разработка, v0.20+

**Рекомендация:** СРЕДНЯЯ — полезен для AI code review, но delta + lazygit покрывают существующие нужды

---

### 15. tuitab

**Что это:** Keyboard-driven терминальный explorer для табличных данных — CSV, TSV, JSON, JSONL, YAML, TOML, Parquet, Arrow, Excel, SQLite, DuckDB.

**Что умеет:**
- Фильтрация, сортировка, pivot-ы, joins
- Computed columns и charts
- Keyboard-driven навигация
- Поддержка 12+ форматов данных

**Почему интересно:** Это терминальный data explorer который нативно обрабатывает структурированные форматы данных. Возможности pivot/join/computed-column делают его терминальной таблицей.

**Что уже есть:** jq, yq, miller (установлены) — текстовая обработка данных. tuitab — визуальный TUI explorer.

**Отличие:** tuitab предоставляет визуальное TUI-взаимодействие с табличными данными. jq/yq/miller — CLI фильтры. Другой парадигмой.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (PR #554785, добавлен как `tuitab`). Проверено.

**Open Source:** Да

**Зрелость:** Стабильный, в nixpkgs

**Рекомендация:** ВЫСОКАЯ — в nixpkgs, уникальное визуальное исследование данных

---

### 16. swpui

**Что это:** TUI для search and replace с фокусом на эргономике, скорости и case-awareness.

**Что умеет:**
- Интерактивный search and replace по файлам
- Case-aware matching
- Эргономичный keyboard-driven интерфейс
- Быстрый, сфокусированный инструмент

**Почему интересно:** Специализированный search-and-replace TUI. Не универсальный инструмент — специально оптимизированный для workflow find-and-replace.

**Что уже есть:** ripgrep (установлен для поиска), sed/awk для замены. swpui комбинирует оба в интерактивном TUI.

**Отличие:** Интерактивный search-and-replace TUI против CLI ripgrep + sed. Другой workflow парадигмой.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (PR #524889, `swpui`). Проверено.

**Open Source:** Да

**Зрелость:** Стабильный, в nixpkgs

**Рекомендация:** СРЕДНЯЯ — полезен но ripgrep + sed уже покрывают это

---

### 17. taskwarrior-tui

**Что это:** Terminal user interface для taskwarrior.

**Что умеет:**
- Интерактивное управление задачами
- Keyboard-driven
- Интеграция с taskwarrior CLI

**Почему интересно:** Если taskwarrior когда-нибудь будет установлен, это предоставит TUI интерфейс. Но taskwarrior нет в текущем стеке.

**Что уже есть:** planify (установлен — менеджер задач). taskwarrior-tui требует taskwarrior.

**Отличие:** Требует backend taskwarrior. planify уже является менеджером задач.

**Установлен:** НЕТ (taskwarrior не установлен)

**NixOS:** В nixpkgs (`pkgs.taskwarrior-tui`). Проверено.

**Open Source:** Да (MIT)

**Зрелость:** Стабильный

**Рекомендация:** НИЗКАЯ — требует taskwarrior, planify уже установлен

---

### 18. tuxedo

**Что это:** Быстрый, keyboard-driven terminal UI для todo.txt.

**Что умеет:**
- Интерактивное управление todo.txt
- Keyboard-driven
- Быстрый, минималистичный

**Почему интересно:** Поддержка формата todo.txt с красивым TUI. Но planify уже является task-инструментом.

**Что уже есть:** planify (установлен). tuxedo требует формат todo.txt.

**Отличие:** Другой формат управления задачами (todo.txt vs формат planify).

**Установлен:** НЕТ

**NixOS:** В nixpkgs (`pkgs.tuxedo`). Проверено.

**Open Source:** Да

**Зрелость:** Стабильный

**Рекомендация:** НИЗКАЯ — planify уже покрывает управление задачами

---

### 19. tooi

**Что это:** Text-based user interface для Mastodon, Pleroma и друзей.

**Что умеет:**
- Терминальный Mastodon клиент
- Textual TUI
- Интерактивный просмотр социальных медиа

**Почему интересно:** Терминальный Mastodon клиент. Нишевая но интересная задача для terminal-first workflow.

**Что уже есть:** discord, ayugram-desktop (установлены как GUI приложения). Нет терминального социального медиа клиента.

**Отличие:** Терминальный социальный медиа клиент. Совершенно другая категория.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (PR #557307, `tooi`). Проверено.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — нишевая но интересная, terminal-first социальные медиа

---

### 20. bitchat-tui

**Что это:** TUI клиент для BitChat — secure, anonymous, peer-to-peer chat over BLE.

**Что умеет:**
- End-to-end encrypted P2P chat
- Bluetooth Low Energy транспорт
- Терминальный интерфейс
- Off-grid communication

**Почему интересно:** Это самый необычный инструмент который я нашёл. Терминальный зашифрованный P2P чат через Bluetooth. Полностью off-grid communication.

**Что уже есть:** Ничего сопоставимого. Нет зашифрованного P2P чат инструмента.

**Отличие:** Совершенно уникальная категория — зашифрованный P2P чат через BLE в терминале.

**Установлен:** НЕТ

**NixOS:** В nixpkgs (PR #429235, `bitchat-tui`). Проверено.

**Open Source:** Да

**Зрелость:** Ранняя стадия, экспериментальный

**Рекомендация:** СРЕДНЯЯ — экстремально нишевая, экспериментальная, но увлекательная концепция

---

## 📊 Визуализация Системы

### 21. kite

**Что это:** Современный cross-platform TUI системный монитор ресурсов на Rust. Вдохновлён btop++.

**Что умеет:**
- Real-time CPU мониторинг (per-core, frequency, load averages) с sparkline графиками
- Memory & swap usage с historical graphs и bar gauges
- Disk I/O rates и filesystem usage
- Network interface traffic с auto-scaling graphs
- GPU мониторинг (NVIDIA NVML)
- Docker container monitoring
- Kubernetes pod monitoring (опционально)
- SSH remote monitoring (опционально)
- Prometheus metrics exporter (опционально)
- Настраиваемые alert rules в TOML
- 11 встроенных тем
- Vim-style навигация
- Process management с сигналами

**Почему интересно:** kite — самый feature-rich современный системный монитор который я нашёл. Система alert rules, Docker/K8s интеграция и Prometheus exporter уникальны. TOML конфигурация чистая.

**Что уже есть:** btop (установлен). btop — солидный монитор но не хватает kite системы alert rules, Docker/K8s интеграции и Prometheus exporter.

**Отличие:** kite добавляет настраиваемые alert rules, Docker/K8s мониторинг, Prometheus exporter и SSH remote monitoring. btop — более простой монитор.

**Установлен:** НЕТ (btop установлен но с другим набором возможностей)

**NixOS:** Нет в nixpkgs. Доступен через `cargo install kite` или GitHub release.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — btop уже установлен, kite добавляет возможности но может быть overkill

---

### 22. neotop

**Что это:** Linux-first терминальный системный монитор с per-core CPU spectrum, NVIDIA/AMD/Intel GPU dashboards, KVM hypervisor insight, container/runtime process grouping.

**Что умеет:**
- Per-core CPU spectrum с SMT/NUMA grouping
- Multi-vendor GPU dashboards (NVIDIA, AMD, Intel)
- KVM hypervisor insight
- Universal process grouping (каждая строка в named aggregate)
- Catppuccin темы
- Один бинарник, нет демонов, нет конфигурации
- macOS порт с функциональным паритетом

**Почему интересно:** neotop имеет самый сложный GPU мониторинг и process grouping. Подход «каждая строка живёт в named aggregate» уникален — нет headerless «misc» tail. KVM insight ценен для virtualization setup.

**Что уже есть:** btop (установлен). btop имеет базовый process monitoring но нет GPU dashboards или KVM insight.

**Отличие:** neotop добавляет GPU dashboards (multi-vendor), KVM hypervisor insight и сложный process grouping. btop имеет базовый CPU/RAM/disk/network.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install neotop` или GitHub release.

**Open Source:** Да

**Зрелость:** Активная разработка, v0.28+

**Рекомендация:** ВЫСОКАЯ — GPU мониторинг + KVM insight + process grouping уникальны

---

### 23. narsil

**Что это:** Терминальный системный монитор ресурсов на Rust — быстрый, читаемый и GPU-aware. Назван в честь меча Арагорна.

**Что умеет:**
- Вкладки Overview, CPU, Memory, Network, Disks, Processes, GPU
- Braille charts для CPU
- Per-char label inversion
- Disk usage bars
- Status bar с keybindings
- Локализованный UI (EN/DE/FR/ES)
- GPU мониторинг: AMD + NVIDIA + Intel (Linux)
- `cargo install narsil` или AUR/AppImage/Windows

**Почему интересно:** narsil комбинирует braille charts с GPU мониторингом и локализацией. Braille-based CPU визуализация визуально отличается.

**Что уже есть:** btop (установлен). narsil добавляет braille charts и GPU мониторинг.

**Отличие:** Braille charts + GPU мониторинг + локализация. btop имеет стандартные bar charts.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install narsil`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — braille charts визуально интересны но btop покрывает базовые нужды

---

### 24. dreidel

**Что это:** Быстрый, keyboard-driven Linux-first терминальный системный монитор с чистой dashboard layout и focused drill-down views.

**Что умеет:**
- CPU — per-core line charts с scrollable history и per-core temperatures
- Network — per-interface RX/TX rates с full-screen graph drill-down
- Disk — per-device capacity info с read/write rate graphs
- Process — sortable, filterable с detail overlay и signal support
- Status bar — clock, uptime, load averages, RAM/swap gauges
- 4 layout: sidebar, classic, dashboard, grid
- TOML конфигурация

**Почему интересно:** Layout system и drill-down подход dreidel уникальны. Network и disk drill-down views (full-screen graphs) особенно хорошо спроектированы.

**Что уже есть:** btop (установлен). btop имеет похожие возможности но dreidel layout system и drill-down UX отличаются.

**Отличие:** Dreidel layout presets и drill-down UX отличаются от подхода btop.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install dreidel`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — btop уже покрывает системный мониторинг

---

### 25. vitals

**Что это:** Терминальный монитор ресурсов для Linux построенный на notcurses. Отображает CPU, memory, network, storage и thermal data в responsive multi-panel TUI.

**Что умеет:**
- Панели CPU, Memory, Network, Storage, Thermal
- 24-bit color используя Catppuccin Mocha палитру
- Adaptive layout (3-column wide, 2-column medium, stacked narrow)
- Построен на notcurses (нет предустановленной зависимости)

**Почему интересно:** Построен на notcurses, что значит доступ к продвинутой терминальной графике. Adaptive layout система уникальна.

**Что уже есть:** btop (установлен). vitals использует notcurses для рендеринга.

**Отличие:** notcurses-based рендеринг с adaptive layout. btop использует другой рендеринг.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через source build (CMake).

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — notcurses рендеринг интересен но btop покрывает нужды

---

### 26. tempest-monitor

**Что это:** Потрясающий, real-time терминальный системный монитор для macOS и Linux. Построен на Rust.

**Что умеет:**
- Вкладки Overview, CPU, Memory, Disks, Network, Processes, GPU, Services, Sockets
- Historical persistence (7-day rolling window в SQLite)
- Prometheus-compatible exporter
- PNG/JSON machine-state snapshots
- Intelligent alerting с desktop notifications
- Full async engine (tokio)
- macOS: powermetrics для GPU/power metrics
- Linux: sysfs/hwmon для temperature/GPU
- NVIDIA NVML поддержка

**Почему интересно:** tempest-monitor имеет самый comprehensive feature set — historical persistence, Prometheus exporter, PNG snapshots, и macOS-specific powermetrics интеграция. 7-day SQLite history уникальна.

**Что уже есть:** btop (установлен). tempest-monitor добавляет historical persistence и Prometheus export.

**Отличие:** 7-day historical persistence, Prometheus exporter, PNG snapshots. btop не имеет history.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install tempest-monitor`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — historical persistence уникальна но btop покрывает базовые нужды

---

### 27. puls

**Что это:** Unified system monitoring and management tool для Linux. Комбинирует resource monitoring с system administration.

**Что умеет:**
- CPU, Memory, Disk, Network, GPU monitoring
- Systemd service management (start/stop/restart/enable/disable)
- Journal log viewer
- GRUB configuration editor
- Container engine integration (Docker socket)
- Process tree с resource usage score
- Language detection (Turkish/English)
- Read-only и read/write modes

**Почему интересно:** puls комбинирует monitoring AND system administration в одном TUI. Можно мониторить services AND управлять ими AND редактировать GRUB AND просматривать journal logs — всё в одном инструменте.

**Что уже есть:** btop (monitoring), systemctl (service management), journalctl (logs). puls комбинирует все три.

**Отличие:** Unified monitoring + administration + GRUB editing + journal viewing в одном TUI.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install puls` или GitHub release.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — unified admin+monitor интересен но требует sudo для полной функциональности

---

### 28. voidmon

**Что это:** Sleek, hacker-aesthetic терминальный системный монитор на Go.

**Что умеет:**
- CPU, Memory, Disk, I/O, Network, GPU, Power, Processes
- Cross-platform GPU support (NVIDIA, AMD, Intel, Apple Silicon)
- Power/battery monitoring
- Top 15 процессов по CPU
- One-liner install

**Почему интересно:** Hacker-aesthetic дизайн и Go-based реализация делают его лёгким и визуально отличным.

**Что уже есть:** btop (установлен). voidmon — более простой альтернативный.

**Отличие:** Go-based, hacker aesthetic, проще чем btop.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `go install` или GitHub releases.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** НИЗКАЯ — btop уже установлен и более feature-rich

---

### 29. xtop

**Что это:** Modern, cross-platform TUI системный монитор на Rust. Вдохновлён btop.

**Что умеет:**
- CPU per-core с temperature sensing
- RAM и Swap monitoring с historical chart
- Network RX/TX tracking per interface
- Storage и Disk I/O visualization
- Process list с live search
- GPU и Battery monitoring (stub)
- 13 color тем с custom theme support через JSONC
- 7 built-in layouts с custom layout support через JSONC
- Full-screen mode для любого виджета
- Configurable alert thresholds

**Почему интересно:** Похож на btop но с JSONC конфигурацией и большим количеством layout options. Theme system через JSONC интересна.

**Что уже есть:** btop (установлен). xtop — btop alternative.

**Отличие:** JSONC конфигурация, больше layouts. Но btop уже установлен.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install xtop`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** НИЗКАЯ — btop уже установлен, xtop — альтернатива

---

## 🧬 Nix / System Internals

### 30. nixmate

**Что это:** Все ваши NixOS инструменты в одном TUI — generations, rebuilds, services, errors, и многое другое.

**Что умеет:**
- Generations: browse, diff, delete, pin, restore. Side-by-side package comparison
- Error Translator: вставьте Nix ошибку, получите человеческое объяснение + фикс. 50+ паттернов. AI fallback (Claude/OpenAI/Ollama)
- Services & Ports: systemd + Docker + Podman в одном view. Port mapping. Start/stop/restart. Live logs
- Storage: Disk dashboard. Store breakdown (live/dead paths). GC, optimize, full clean
- Config Showcase: Auto-generate system poster + config architecture diagram как SVG
- Options Explorer: search.nixos.org в терминале. Fuzzy search, tree browsing
- Rebuild: Live nixos-rebuild dashboard. 5-phase progress. Post-build diff
- Flake Inputs: Selective per-input updates
- Package Search: Fuzzy search across 100k+ packages
- Nix Doctor: Health score 0-100. Automated checks с one-click fixes
- Pipe mode: `nixos-rebuild switch 2>&1 | nixmate`

**Почему интересно:** Это ultimate NixOS management TUI. Заменяяет `nixos-rebuild`, `nix-collect-garbage`, `nix search`, `systemctl` и многое другое одним keyboard-driven инструментом. AI error translator и Nix Doctor уникальны.

**Что уже есть:** nix (установлен), nix flake commands, systemctl. nixmate предоставляет unified TUI интерфейс для всего этого.

**Отличие:** Unified TUI для всех NixOS операций + AI error translation + health score. Нет аналога в текущем стеке.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix run github:manelinux/nixmate` или `nix profile install github:manelinux/nixmate`.

**Open Source:** Да

**Зрелость:** Активная разработка, 10 модулей, 13 тем, EN/DE

**Рекомендация:** ВЫСОКАЯ — comprehensive NixOS management, AI error translator, Nix Doctor

---

### 31. nixard

**Что это:** Interactive terminal UI для исследования NixOS package closures, анализа реальных installation costs, и генерации ready-to-use Nix declarations.

**Что умеет:**
- Package exploration с локальной SQLite базой данных
- Real closure analysis (dependency inspection)
- Local store auditing
- Configuration inspection (детектирует configuration.nix, flakes, Home Manager)
- Export/history management
- Встроенный `.nix` редактор
- Mark packages и export как `.nixard` файлы
- Persistent export history
- `.narinfo` caching для fast repeated lookups

**Почему интересно:** nixard предоставляет real closure analysis — можно увидеть точно что пакет потянет за собой перед установкой. Локальная SQLite база означает что поиск мгновенный без сетевого доступа.

**Что уже есть:** nix commands (установлены). nixard предоставляет визуальный TUI для package exploration который nix CLI не имеет.

**Отличие:** Visual TUI для package exploration с real closure analysis и локальной базой данных. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix run github:manelinux/nixard` или `nix profile install github:manelinux/nixard`.

**Open Source:** Да

**Зрелость:** Активная разработка, NixOS 26.05 совместим

**Рекомендация:** ВЫСОКАЯ — closure analysis и visual package exploration уникальны

---

### 32. verynix (vx)

**Что это:** Запустите любую версию любого Nix пакета одной командой.

**Что умеет:**
- `vx hugo-0.139.0 build` — резолвит версию, находит nixpkgs commit, запускает
- Использует Nixhub API для version resolution
- `vx hugo serve` — запустить любую версию пакета
- `vx --verbose` — показать детали резолва

**Почему интересно:** vx решает проблему «какой nixpkgs commit имеет эту версию?». Это как `nix run` но с version resolution встроенной.

**Что уже есть:** nix run (установлен). vx добавляет version resolution.

**Отличие:** Автоматическая version resolution через Nixhub API. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix run github:mipmip/verynix`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — полезен для тестирования конкретных версий пакетов, но nix run покрывает базовые нужды

---

### 33. nxv

**Что это:** Nix Version Index. Молниеносно быстрый CLI для нахождения любой версии любого Nix пакета.

**Что умеет:**
- Fast search (Bloom filter + SQLite FTS5)
- Version history — когда каждая версия была введена
- CLI, HTTP API server с web UI, или remote API
- NixOS module (systemd service с automatic index updates)
- ~10MB static binary, ~190MB compressed index
- 9+ лет истории nixpkgs
- Agent Skills-standard skill для AI coding agents
- Shell completions для bash, zsh, fish

**Почему интересно:** nxv индексирует всю историю пакетов nixpkgs. Agent skills интеграция означает что AI coding agents могут использовать его нативно. HTTP API + web UI — приятный бонус.

**Что уже есть:** nix search (установлен но медленный, нет history). nxv предоставляет мгновенный version history search.

**Отличие:** Complete nixpkgs version history index с мгновенным поиском. AI agent skills.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nxv` binary или `nix run`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — полезен для package version discovery, но nix search покрывает базовые нужды

---

### 34. super-comma (,)

**Что это:** Instant Nix Runner (Rust). Ultra-fast, zero-dependency Nix command runner powered by nixpkgs-multiverse.

**Что умеет:**
- `, ripgrep -i "pattern"` — запускает бинарники напрямую через nix run
- `,s hello cowsay` — интерактивный shell с несколькими пакетами
- `,v python3` — динамически перечисляет все historical versions
- Version constraints: `nodejs@20`, `python3."3.8.9"`
- Custom flake URIs: `f=github:ksv/repo1#tool`
- `--sandbox` mode с landrun
- `--nom` для nix-output-monitor progress bars
- Cross-platform sandboxing (Linux landrun, macOS sandbox-exec)

**Почему интересно:** Comma-based command syntax — самый быстрый способ запускать Nix пакеты. Sandboxing и version constraints мощные. nixpkgs-multiverse backend даёт доступ ко всем historical versions.

**Что уже есть:** nix run (установлен). super-comma предоставляет более быстрый синтаксис и version resolution.

**Отличие:** Ultra-fast syntax, version resolution, sandboxing. Но nix run покрывает базовые нужды.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix profile install github:sayavc/super-comma-nix` или `cargo install`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — быстрый Nix runner но nix run уже работает

---

### 35. nixy

**Что это:** Simple Nix package manager (Rust). asdf/Homebrew alternative using Nix.

**Что умеет:**
- `nixy install ripgrep` — установить с version constraints
- `nixy list` — увидеть установленные пакеты с версиями
- `nixy search python` — найти пакеты + версии
- `nixy profile` — интерактивный TUI profile selector
- Declarative `nixy.json` конфигурация
- Sync across machines через `nixy sync`
- Profile support (work, personal)
- Tab completion для zsh/bash

**Почему интересно:** nixy предоставляет простой CLI интерфейс для Nix пакетов, похожий на Homebrew/asdf. Profile system и declarative config делают управление пакетами跨 машинами лёгким.

**Что уже есть:** nix profile (установлен). nixy предоставляет более простой интерфейс и profile management.

**Отличие:** Simple CLI interface + profile management + declarative config. Но nix profile уже работает.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix profile install github:yusukeshib/nixy`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — simpler Nix package management но nix profile уже работает

---

### 36. nix-pretty

**Что это:** Преобразует раздутый nix path prefix в nix: в терминальном выводе. Rust wrapper который сворачивает `/nix/store/...` пути в читаемые `nix:package-name/path`.

**Что умеет:**
- Переписывает shell output в реальном времени
- Сворачивает `/nix/store/hash-package-name/path` → `nix:package-name/path`
- Запускает shell в PTY, forwards stdin, переписывает output
- Работает с любым shell, любым инструментом
- `shell.nix` integration hook

**Почему интересно:** Это pure output-rewriting инструмент который делает Nix's verbose store paths читаемыми. Маленький утилитарий с большим UX impact.

**Что уже есть:** nix (установлен) с verbose store paths. nix-pretty очищает вывод.

**Отличие:** Real-time output rewriting для Nix store paths. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install nix-pretty` или `nix-build`.

**Open Source:** Да

**Зрелость:** Стабильный

**Рекомендация:** НИЗКАЯ — приятное UX улучшение но не обязательно

---

### 37. niux

**Что это:** Declarative NixOS/home-manager CLI package manager написанный на Rust.

**Что умеет:**
- `niux -Hi firefox` — установить для home
- `niux -Si vim` — установить для system
- Автоматизирует configuration rebuilds
- Built-in generation diffing через nvd integration
- Autocompletion like Pacman/apt
- Поддержка standalone и module home-manager

**Почему интересно:** Похож на nixy но с другим подходом. `-H` (home) и `-S` (system) флаги интуитивны.

**Что уже есть:** nix profile, home-manager. niux предоставляет более простой CLI.

**Отличие:** Simple CLI с home/system distinction. Но nix profile + home-manager уже работают.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix profile install github:sayavc/niux`.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** НИЗКАЯ — nix profile + home-manager уже покрывают это

---

## ✍️ Текст / Unicode

### 38. coretilus

**Что это:** Игривое переосмысление GNU coreutils — коллекция крошечных, смешных и иногда бесполезных command-line инструментов.

**Что умеет:**
- `sl` — Steam Locomotive (rust port)
- `gti` — «Start your engine!» перед коммитом
- `pc` — data deserves a grand tour of your 486
- `mr` — Land the rocket without crashing it
- `dog` — A Dog chasing a domain
- Планируется больше: `grpe` (searches nothing), `adn` (more), `...yuor` (own ideas)

**Почему интересно:** Чистое веселье. Когда вы ошибочно вводите `git` → `gti`, вместо ошибки вы получаете анимацию паровоза. Это «toy» категория сделана правильно.

**Что уже есть:** Ничего сопоставимого. Нет coreutils parody инструментов.

**Отличие:** Чистое веселье, typo-triggered анимации. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `cargo install coretilus` или `.deb`/`.rpm` пакеты.

**Open Source:** Да (Apache-2.0)

**Зрелость:** Ранняя (v0.3.0)

**Рекомендация:** НИЗКАЯ — чистый весёлый toy, не обязательно

---

## 🛠 Unix Utilities

### 39. tuitab (уже перечислен в разделе TUI)

Также релевантен здесь как data processing инструмент. Уже покрыт.

---

## 🎲 Fun

### 40. nix-bonsai

**Что это:** Бонсай-деревогенератор написанный на 100% чистом Nix.

**Что умеет:**
- Live animation mode (смотрите дерево расти в реальном времени)
- Print mode (статическое дерево для терминала)
- Кастомизируемые seed, life, multiplier, animation speed
- ANSI colored output
- Весь алгоритм в чистых Nix expressions
- `nix run github:your-username/nix-bonsai -- --print`

**Почему интересно:** Это генератор деревьев написанный ВОСТОЧНО в Nix expressions. RNG, tree growth algorithm и ANSI rendering — всё Nix код. Это демонстрация вычислительных возможностей Nix.

**Что уже есть:** Ничего сопоставимого. Нет терминального генератора деревьев.

**Отличие:** Pure Nix implementation. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через `nix run github:...`.

**Open Source:** Да

**Зрелость:** Ранняя

**Рекомендация:** НИЗКАЯ — весело но чисто экспериментально

---

## 🌀 Weird / Experimental

### 41. boxxy

**Что это:** Самоулучшающийся Linux терминал powered by AI characters. Full terminal emulator с agentic AI layer (BoxxyClaw).

**Что умеет:**
- AI characters которые читают terminal buffer, запоминают preferences, автономно фиксят зависимости
- `Ctrl+/` для активации AI agent
- GTK4/Adwaita UI
- Headless terminal engine (boxxy-vte)
- Agentic intelligence layer (boxxy-claw)
- MCP support
- Characters, skills, toolbox

**Почему интересно:** Это самый амбициозный терминальный проект который я нашёл. Это не просто терминал — это AI-powered operating system внутри вашего терминала. Agentic AI layer может автономно управлять вашей системой.

**Что уже есть:** Ничего сопоставимого. Нет AI-powered terminal emulator.

**Отличие:** AI agentic terminal emulator. Совершенно новая категория.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Preview стадия. Требует GTK 4.22 + libAdwaita 1.9.

**Open Source:** Да

**Зрелость:** Preview/early access

**Рекомендация:** НИЗКАЯ — очень ранняя стадия, требует специфичную GTK версию, не production-ready

---

### 42. wibwob-dos

**Что это:** Terminal-native desktop shell где люди и AI агенты делят один экран. Operating system которая живёт внутри терминала.

**Что умеет:**
- Window manager, menu bar, overlapping draggable windows
- 22+ microapps: drum machines, ant colony simulations, code editor, file manager
- AI agent (Wib & Wob) embedded как desktop citizen
- Control API на порту 8099
- Microapp SDK со stacks, rows, grids, tabs, filterable lists
- Themes, hot-switchable
- Работает в любом терминале с 256-colour и mouse support

**Почему интересно:** Это полная desktop среда внутри терминала. Самый амбициозный «terminal OS» проект. Microapp экосистема и AI agent интеграция уникальны.

**Что уже есть:** Ничего сопоставимого. Нет terminal desktop environment.

**Отличие:** Complete terminal desktop OS с AI agent. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Требует Bun, терминал с 256-colour + mouse support.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** НИЗКАЯ — экспериментальный, требует Bun, не production-ready

---

### 43. seance

**Что это:** GTK4 terminal multiplexer для Linux который авто-детектирует Claude Code, Codex, и Pi сессии и отслеживает их статус.

**Что умеет:**
- Авто-детекция AI coding agent сессий (Claude Code, Codex, Pi)
- Отслеживание статуса (working, waiting for permission, idle) в sidebar
- Desktop notifications для permission requests и task completions
- GTK4 + libadwaita с blur/transparency
- GPU-accelerated terminal rendering через libghostty
- Horizontal strip layout (niri-inspired)
- `seance ctl` API для scripting
- Workspaces, session persistence, tabs within columns
- AI agent skill file для `seance ctl` API

**Почему интересно:** Специально спроектирован для управления AI coding agent сессиями. Auto-detection Claude Code/Codex/Pi и status tracking уникальны.

**Что уже есть:** tmux (установлен), но нет AI agent session management.

**Отличие:** AI agent session management с auto-detection и status tracking. Нет аналога.

**Установлен:** НЕТ

**NixOS:** Нет в nixpkgs. Доступен через flake, AUR, или AppImage. Требует Zig 0.15.2+, GTK4, OpenGL 4.3+.

**Open Source:** Да

**Зрелость:** Активная разработка

**Рекомендация:** СРЕДНЯЯ — полезен для AI agent management но требует специфичных зависимостей

---

### 44. claurst

**Что это:** Open-source, multi-provider terminal coding agent построенный на Rust. Clean-room reimplementation Claude Code behavior.

**Что умеет:**
- Multi-provider support (Claude, OpenAI, и др.)
- TUI pair programmer с rich UI
- Plugin system
- Companion named Rustle
- Chat forking, memory consolidation
- Agent Client Protocol (ACP) интеграция
- `/share` для sharing сессий через GitHub Gists
- `/goal` для sustained multi-turn objectives
- `ultracode` — highest effort level с subagents
- Voice/microphone support

**Почему интересно:** Это Claude Code альтернатива которая работает в терминале. Multi-provider support и ACP интеграция делают его гибким.

**Что уже есть:** AI CLI tools (opencode, claude-code, lilo-code) уже добавлены как npm comments в tools.nix. claurst — terminal-based alternative.

**Отличие:** Terminal-based AI coding agent с multi-provider support. Но AI tools уже в конфиге как npm comments.

**Установлен:** НЕТ (AI tools — npm comments, не установлены)

**NixOS:** Нет в nixpkgs. Доступен через `npm install -g claurst` или `cargo install`.

**Open Source:** Да (MIT)

**Зрелость:** Beta v0.1.7

**Рекомендация:** СРЕДНЯЯ — terminal AI coding agent, но AI tools уже запланированы как npm installs

---

## Already Installed — Potentially Underused

### chafa

**Что уже делает:** ANSI/Unicode/Sixel терминальный рендеринг изображений.

**Что вы можете не использовать:**
- Animated GIF rendering (`chafa --animate`)
- Python/JS bindings для встраивания
- Terminal capability detection
- Multiple symbol sets (block, half-block, braille, и т.д.)
- Sixel protocol output для поддерживаемых терминалов

**Предложение:** Проверьте используется ли `chafa --animate` для анимированного контента. Python bindings могут быть интегрированы в скрипты.

---

### ImageMagick

**Что уже делает:** Image conversion, manipulation, composition.

**Что вы можете не использовать:**
- `convert` для terminal-compatible output generation
- `magick` для batch processing
- `compare` для diffing images
- `identify` для metadata extraction
- `montage` для image grids
- `display` (если X11 доступен)

**Предложение:** ImageMagick's `convert` может генерировать ANSI-compatible output. В комбинации с chafa это мощный image processing pipeline.

---

### ffmpeg_7

**Что уже делает:** Video/audio processing.

**Что вы можете не использовать:**
- `ffmpeg` для generating terminal-compatible video frames
- `ffprobe` для metadata extraction
- `ffmpeg` filters для создания ASCII art из видео
- Streaming to terminal через `ffmpeg -f rawvideo`

**Предложение:** ffmpeg может pipe video frames к chafa или другим terminal renderers для terminal video playback.

---

### neovim

**Что уже делает:** Modal text editor с LSP, treesitter, lazy.nvim.

**Что вы можете не использовать:**
- `nvim` как terminal IDE (с lazyide-style features)
- Terminal integration через `:term`
- `nvim-treesitter` для syntax-aware terminal rendering
- Neovim как markdown/terminal previewer

**Предложение:** Neovim's `:term` команда может заменить многие terminal tools. Treesitter интеграция может питать terminal previews.

---

### yazi

**Что уже делает:** Terminal file manager с async I/O, previews, sixel/kitty image rendering.

**Что вы можете не использовать:**
- `magick` plugin для ImageMagick integration
- `video` previewer для ffmpeg-based video previews
- `pdf` previewer для PDF inspection
- `font` previewer для font inspection
- `git` fetcher для repository info
- Custom opener rules для специализированных workflow

**Предложение:** Yazi's plugin system обширен. `magick` и `video` previewers особенно недоиспользованы.

---

## Summary: Top Discoveries

### Tier 1 — Must Consider (Unique Capability + NixOS Available)

| # | Tool | Category | Why | NixOS |
|---|------|----------|-----|-------|
| 1 | **tuitab** | TUI/Data | Visual tabular data explorer | ✅ in nixpkgs |
| 2 | **nixmate** | Nix/System | Unified NixOS management TUI | ✅ via flake |
| 3 | **nixard** | Nix/System | Visual package closure analysis | ✅ via flake |
| 4 | **timg** | Image/Media | Terminal image+video viewer | ✅ in nixpkgs |
| 5 | **notcurses** | Image/Media | Library + bundled tools (ncls, ncplayer) | ✅ in nixpkgs |
| 6 | **px2ansi-rs** | Graphics | 10 rendering styles, asset manager | ❌ cargo install |
| 7 | **phosphor** | Graphics | tmux-compatible image/PDF viewer | ❌ npm install |
| 8 | **neotop** | System Monitor | GPU dashboards + KVM insight | ❌ cargo install |
| 9 | **ratty** | Graphics | 3D terminal graphics (novel category) | ✅ via flake |
| 10 | **milli** | Graphics | Animated ASCII + Neovim integration | ❌ npm install |

### Tier 2 — Interesting but Niche

| # | Tool | Category | Why | NixOS |
|---|------|----------|-----|-------|
| 11 | **kite** | System Monitor | Alert rules + Docker/K8s monitoring | ❌ cargo install |
| 12 | **swpui** | TUI | Search-and-replace TUI | ✅ in nixpkgs |
| 13 | **tooi** | TUI | Terminal Mastodon client | ✅ in nixpkgs |
| 14 | **bitchat-tui** | TUI | Encrypted P2P chat over BLE | ✅ in nixpkgs |
| 15 | **hunk** | Git/Dev | AI-powered diff reviewer | ✅ via flake |
| 16 | **seance** | Terminal | AI agent session manager | ❌ flake/AppImage |
| 17 | **verynix (vx)** | Nix/System | Run any package version | ✅ via flake |
| 18 | **nxv** | Nix/System | Version history index | ❌ standalone |
| 19 | **super-comma** | Nix/System | Instant Nix runner | ✅ via flake |
| 20 | **fidelitty** | Graphics | Custom font image rendering | ❌ cargo install |

### Tier 3 — Pure Fun / Experimental

| # | Tool | Category | Why | NixOS |
|---|------|----------|-----|-------|
| 21 | **coretilus** | Fun | Coreutils parody (sl, gti, mr) | ❌ cargo install |
| 22 | **nix-bonsai** | Fun | Pure Nix tree generator | ❌ via flake |
| 23 | **vinz** | Graphics | 3D raymarching terminal art | ❌ cargo install |
| 24 | **anima (yzs)** | Fun | Terminal animation toolkit | ✅ via flake |
| 25 | **boxxy** | Experimental | AI terminal emulator | ❌ preview |
| 26 | **wibwob-dos** | Experimental | Terminal desktop OS | ❌ Bun required |

---

## Already Installed — Underused Capabilities

| Tool | Underused Capability | Suggestion |
|------|---------------------|------------|
| chafa | Animated GIF rendering, Python bindings | Попробуйте `chafa --animate`, используйте Python API |
| ImageMagick | Terminal-compatible output, montage | `magick convert` для ANSI output |
| ffmpeg_7 | Terminal video playback via frame piping | `ffmpeg -f rawvideo | chafa` |
| yazi | magick/video/pdf previewers | Включите `magick` и `video` previewers |
| neovim | `:term` command, treesitter previews | Используйте nvim как terminal IDE |

---

## Next Steps

1. **Review this catalog** and identify which tools interest you
2. **Select tools to install** — I will not install anything without your explicit choice
3. **For selected tools:**
   - Verify nixpkgs packaging status
   - Add to appropriate existing feature module
   - Configure to match theme/colors
   - Test build and run
   - Update Devlog
4. **Architecture rules:**
   - No new modules unless absolutely necessary
   - Use existing `home/features/cli/`, `home/features/media/`, etc.
   - Maintain theme/colors consistency
   - Don't break existing workflows
