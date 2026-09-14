# NixOS / Home Manager — Тотальный аудит конфигурации `~/nixos-config`

*Дата аудита: 14.09.2026. Целевое железо: основная рабочая станция (laptop MSI, x86-64, AMD Radeon gfx1030, UEFI).*

---

## Executive Summary

Конфиг — **результат миграции из Ubuntu WSL + копирования чужого/AI-сгенерированного шаблона**. Он весьма богат по задумке (Neovim + Lazy.nvim, Hyprland, Waybar, Yazi, античный стек рокомов), но в текущем виде **не соберётся как NixOS-флейк** из-за серии неопределённых идентификаторов и архитектурных конфликтов, а на реальном железе без доработки **не поднимется до десктопа** (нет display manager, нет PipeWire, нет `fileSystems`, нет GPU-стека, GRUB на `/dev/sda`, пятак WSL-артефактов).

**Цифры (после исправлений): работающая система — 100% воспроизводима, но сейчас это ~30%.** Ниже — полный разбор.

---

# Раздел 1. Структура и иерархия системы

## 1.1 Общая картина

```
flake.nix
├── inputs: nixpkgs 23.11, home-manager 23.11, Hyprland (main), hypr-niri (plugin)
├── nixosConfigurations."msi-laptop"
│   ├── ./modules/common            (пустой заглушка)
│   ├── ./system/configuration.nix
│   │   ├── ./system/packages.nix
│   │   └── ./system/home.nix        <-- импортирует ../artlaus (!!)
│   └── home-manager.users.artlaus = import ./artlaus   (!!)
├── homeConfigurations."artlaus"    (отдельный standalone-HM)
└── devShells.default
```

Полностью **модульная** структура, но с тройным наслоением:

1. **NixOS системный слой** — `system/configuration.nix` (+ `packages.nix`, `home.nix`).
2. **Home Manager как системный модуль** — `home-manager.users.artlaus = import ./artlaus` (правильный путь).
3. **Артефакт миграции** — `system/home.nix` — *это NixOS-модуль* (`{ config, pkgs, inputs, lib, ... }`), который **`imports = [ ../artlaus ]`**. То есть home-модуль `artlaus` попадает в дерево NixOS *дважды* — второй раз напрямую как системный модуль, где опций `home.*`, `gtk.*`, `stylix.*`, `programs.yazi`, `programs.waybar` и т.п. **не существует** → **ошибка оценки (evaluation error)**.

Подтверждение: в `flake.nix:52` уже есть `home-manager.users.${username} = import ./artlaus`. Импорт `../artlaus` в `system/home.nix` — **лишний и ломающий**.

Также `modules/common/default.nix`, `modules/home-manager/default.nix`, `modules/home-manager/services/default.nix`, `lib/default.nix` — **пустые заглушки** (мёртвый код), а `system/home.nix:1` дублирует то, что уже делает HM-модуль.

## 1.2 Как части взаимодействуют

| Слой | Что делает | Где |
|---|---|---|
| `configuration.nix` | глобальные настройки: timezone, locale, GRUB, NetworkManager, пользователь, `allowUnfree`, `stateVersion` | `system/configuration.nix` |
| `packages.nix` | системные пакеты, шрифты, systemd-юнит polkit, ollama, nix-ld, gnupg, appimage, thunar, steam, gamemode | `system/packages.nix` |
| Home Manager | `~/.config/*`, `~/.zshrc`, `~/.config/nvim/**`, prompt, темы | `artlaus/**` |
| Скрипты | rofi-media, new-note | `scripts/**` |

**Пересечения пакетов `environment.systemPackages` vs `home.packages`:**
- Дублирования конкретных пакетов почти нет, но есть **дублирование категорий**: `thunar` ставится и системно (`programs.thunar.enable` + `xfce.thunar`), и модульные инструменты размазаны по 4 местам (`system/packages.nix`, `artlaus/features/cli/default.nix`, `artlaus/features/desktop/default.nix`, `waybar/scripts`). Один единственный пользователь — но пакеты живут в трёх несогласованных "койках".

**Systemd:** системный юнит polkit агента объявлен в `packages.nix:26-40`, **и одновременно** запускается в Hyprland через `exec-once = ... nix-instantiate ... polkit ...` (`hyprland.nix:33`). Двойной запуск + runtime-`nix-instantiate` с `<nixpkgs>` (зависимость от NIX_PATH, не воспроизводимо).

---

# Раздел 2. Точечный разбор ключевых подсистем

## 2.1 Neovim — глубокий аудит

**Способ установки:** Home Manager `programs.neovim.enable` + один Nix-плагин `vimPlugins.lazy-nvim` (`cli/nvim/default.nix:13`).

**Способ управления плагинами: ВАРИАНТ C (Lazy.nvim), гибрид.**
- Nix контролирует только сам neovim и загрузчик lazy.nvim.
- **Все ~30 плагинов** тянет `require("lazy").setup({ import = "plugins" })` из `lua/plugins/*.lua` (создаются из Nix-файлов) — **при первом запуске клонируются из GitHub в `~/.local/share/nvim`**.
- Дополнительно `markdown-preview.nvim` при первом запуске **скачивает предкомпилированные бинарники** (`build = vim.fn["mkdp#util#install"]()`).
- `treesitter` — `ensure_installed` качает парсеры из сети на лету.
- `supermaven-nvim` — проприетарный ИИ-комплитер, требует API-ключ и сеть.

**Вывод по философии Nix:** конфиг *наполовину* декларативен. Всё, что lazy скачает сам, — **не воспроизводимо, не откатывается, не изолировано**. Сломанная сеть или удалённый тег плагина = сломанный Neovim, при этом "правильная" версия в Nix store есть. Это **жёлтый флаг**.

**Сравнение вариантов:**
- **A (всё через `vimPlugins`)**: радикально, но теряется lazy-эффект (lazy-loading).
- **B (nixvim)**: лучший компромисс для "идеального декоративного Nvim", но переписывание всех lua в Nix = крупная работа.
- **C (Lazy + Nix-managed спеки)** — **рекомендация для вашей системы**: экспорт `lazy-loader` из `vimPlugins.lazy-nvim` даёт `lazy.setup()` из прописывать в тот же `lua/plugins/`. Т.е. **Nix владеет реестром плагинов + версиями, Lazy остаётся runtime-менеджером**. Это компромисс воспроизводимости и комфорта.
- **D (гибрид текущий)**: сохранить, только если добавить `lazy-lock.json` в git и фиксировать версии — всё равно не заменяет Nix-стор.

**Критические баги Neovim:**
1. **`colorscheme artgreendream` (`init.nix:15`, `bufferline.nix:7`) — нигде не определена.** Нет файла темы, нет плагина. Neovim выдаст `E185`, и схема не применится → дефолтная тема. **Красный флаг.**
2. **API Neovim 0.11 против 0.9.** В `lsp.nix` используются `vim.lsp.config()` / `vim.lsp.enable()` / `client.supports_method()` — это API **Neovim 0.11+**. В nixpkgs `nixos-23.11` neovim = **0.9.5**. Весь блок LSP упадёт с ошибкой "Attempt to call field 'config' (a nil value)". **Красный флаг.**
3. `options.lua:21` включает `undofile`, затем `:27` выключает — противоречие, фактически undo отключён.
4. `cmp.nix:20` — путь `~/.config/home-manager/src/nvim/snippets` **не существует** → снайпеты не грузятся (молча).
5. `formatting&linting.nix` — форматтеры `prettierd/black/isort/nixfmt/typstyle/verible/eslint_d/flake8` **не установлены** ни через Nix, ни через Mason (Mason не настроен, `mason_bin` просто дописывается в PATH). Мосты в `conform`/`lint` будут тихо падать (есть `pcall`). Или потребует runtime-установок → импуризм.
6. `autocmds.lua` — `:source` lua-файлов при сохранении: работает, но противоречит Nix-идее (конфиг читается из store, вручную `source` из домашней копии — рассинхрон).
7. **Ключевая привязка `keymaps.lua:9-10`** — `/` переопределён в `:`, `.` в `/`, `,` в `?`. Это **убивает штатные `.` (повтор последнего изменения) и `,` (обратный f/t)** — для vim-профессионала потеря функциональности. Возможно, осознанно, но предупрежу.
8. Дубли: `vim-tmux-navigator` ставится **дважды** (`plugins/default.nix:26` и `plugins/tmux.nix:6`) через `programs.neovim.plugins` — конфликт merge.

## 2.2 Пакеты и приложения (Steam, Spotify, Discord, Telegram, VLC)

| Приложение | Статус | Место |
|---|---|---|
| Steam | ✅ | `system/packages.nix:119-124` (`programs.steam` + firewall для remote play) |
| Discord | ✅ | `system/packages.nix:208` (`pkgs2.discord`) |
| Telegram | ✅ | `system/packages.nix:209` (`pkgs2.telegram-desktop`) |
| VLC | ❌ **отсутствует** | — (есть `mpv`, но VLC нет) |
| Spotify | ❌ **отсутствует** | — (есть `strawberry`, open-source) |

**Недочёт:** VLC и Spotify (в запросе явно указаны) отсутствуют. Решение: оставить `mpv`/`strawberry` как основу (open-source, лучше), а `spotify` добавить при желании.

**Примеры конкретных путей (по ТЗ):**
- `environment.systemPackages = with pkgs; [ ... pkgs2.discord pkgs2.telegram-desktop ...]` → `system/packages.nix:130-265`.
- `home.packages = with pkgs; [ ... ]` → `artlaus/features/cli/default.nix:24-161`.
- `programs.steam.enable` → `system/packages.nix:119`.

**allowUnfree:** ✅ задан **дважды** — `flake.nix:32` (`config.allowUnfree = true` в `pkgs`) и `configuration.nix:45` (`nixpkgs.config.allowUnfree`). Достаточно одного.

## 2.3 Терминалы — аудит

Установлены **три графических терминала**: Alacritty, WezTerm, Kitty (+ tmux).

- **Alacritty** (`cli/alacritty/alacritty.nix`): хорошая цветовая схема (#001a0d фон, #66FF99 акцент), but **`shell.program = "wsl.exe"`** — WSL-артефакт → на реальном железе при запуске запустится `wsl.exe` и ничего не будет. **Красный флаг.**
- **WezTerm** (`cli/wezterm/wezterm.nix`): богатейшая конфигурация (табы, лидер-клавиша, палитра), но **`default_prog = { "wsl.exe" }`** — тот же WSL-артефакт.
- **Kitty**: только пакет, конфига нет.
- **tmux** (`cli/tmux/tmux.nix`): ок, но завязан на `${TERM}` — а `TERM=alacritty` из sessionVariables при запуске tmux из-под другого терминала даст неверный TERM.

**Вывод:** оставить **один** терминал. Для вашей эстетики (прозрачность, табы, панели, blur) — **WezTerm** как основной, KitTTY — запасной. Alacritty либо удалить, либо оставить как ультра-лёгкий фоллбек. Это устранит дубль и упростит поддержку темы.

## 2.4 Shell (zsh)

- **zsh** + Oh My Zsh + **Antidote** + **Starship** + zoxide + fzf.
- Проблемы:
  1. **`programs.zsh.antidote` (`zsh.nix:92-96`) — опция Home Manager, которой нет в release-23.11** (добавлена в 24.05). При pin'е `release-23.11` — баг: "attribute 'antidote' missing". **Красный флаг при сборке.**
  2. `enableAutosuggestions + enableSyntaxHighlighting` (**HM-встроенные**) **одновременно** с плагинами `zsh-autosuggestions` + `fast-syntax-highlighting` через antidote → **тройная подгрузка**, возможны конфликты подсветки.
  3. Oh My Zsh включён **целиком** (`ohMyZsh.enable = true`) без темы → его дефолтная тема robbyrussell **конкурирует со Starship** за PROMPT.
  4. **zoxide включён трижды**: пакет/плагин `oh-my-zsh.plugins.zoxide`, `programs.zoxide.enableZshIntegration`, `eval "$(zoxide init zsh)"` в initExtra.
  5. **`cd = "z"`** — перезапись критической команды alias'ом: ломает сценарии, предполагающие штатный `cd` (bash-скрипты, `cd -`, `cd ~` в ряде plgu). Обычно лучше `zsh-autosuggestions` + отдельный `z`, или zoxide через `zsh-autosuggestions`... Здесь хотя бы для интерактива. Жёлтый.
  6. **Алиасы-«фантомы»:** `nn = "/home/artlaus/scripts/new_note.sh"` — файла нет (реальный `new-note.nix` лежит в репозитории и не подключён); `d = "delta"` — **delta не установлена**; `pkgs = "nvim ${flakeDir}//nixos/packages.nix"` — реальный путь `system/packages.nix`; `upg = nixos-rebuild ... --upgrade` — флага `--upgrade` у `nixos-rebuild` (flakes) нет.
  7. `y = "yazi"` (алиас) **и** `function y()` (cwd-функция) — конфликт: алиас выигрывает, `cd после выхода из yazi` не работает.
  8. `NVM_DIR` + `nvm.sh` — при том, что Node ставится через Nix (`pkgs2.nodejs_24`). Двойное управление, будет сражаться за `node`.
  9. `GOOGLE_CLOUD_PROJECT="data-avatar-475416-s2"` — выглядящий как тестовый GCP-проект, захардкожен в сессии.
  10. Вендоренный `.antidote` (1.4М), `oh-my-zsh` (18М!), `.zsh_history`, `.zcompdump`, `.zshenv` — **лежат внутри репозитория Nix-конфига**, не используются сборкой (плагины берутся из nixpkgs). Мусор в git/history.

## 2.5 Wayland / Hyprland

**Архитектурные проблемы:**
1. **Нет display manager вообще.** `services.greetd`, `services.displayManager` — ничего. Собрать реальное железо = загрузка в TTY и ручной `Hyprland`. Нужен SDDM или greetd + session-файл (hm создаёт `.desktop` для Hyprland, но запустить его нечем).
2. **`hyprland.nix:15-18` — `inputs.hypr-niri` — переменная `inputs` НЕ передана в модуль** (`{ pkgs, ... }`). `inputs` здесь — undefined → **ошибка оценки. Красный флаг.**
3. Используется `pkgs.hyprland` **из nixpkgs 23.11** (старый Hyprland), а не из flake-инпута `inputs.hyprland` (который задуман как «актуальный»). Флейк-инпут Hyprland фактически мёртв.
4. `plugin { niri-layout { ... } }` + `layout = niri` — расширение `hypr-niri` (szomer) сомнительной совместимости с 23.11 Hyprland; **проверено только вручную**. Если цель — «niri-подобная раскладка», честнее использовать сам **niri** или Hyprland без плагина. Жёлтый + риск.
5. **Polkit запускается дважды** (системный юнит + `exec-once` через `nix-instantiate` — вообще запрещённая практика в рантайме).
6. **Нет `xdg.desktopEntries`, `xdg.portal`** — порталы не настроены (`xdg-desktop-portal-hyprland` не включён), значит скар-экран/файл-пикеры/emit Wayland-селфи будут деградировать.
7. **Нет `swayidle` / автоблокировки** — экран никогда не залочится сам. Экран блокируется только вручную (Super+L).
8. `env = QT_QPA_PLATFORMTHEME,qt5ct` **конфликтует** с глобальным `QT_QPA_PLATFORMTHEME="qt6ct"` из `home.nix:28`. При этом **ни qt6ct, ни qt5ct, ни kvantum в конфиге не установлены** → переменная указывает на несуществующую программу.

## 2.6 Waybar

- Хорошая CSS база (#001a0d + #66FF99 + лаванда), **но**:
  1. `output = "DP-1"` **захардкожен** — на ноутбучном eDP-1 панель не появится. **Красный флаг.**
  2. В `modules-left/right` перечислены только `workspaces`, `nowplaying`, `tray`, `clock`, `battery` — **а настроенные `memory`, `cpu`, `temperature`, `network`, `pulseaudio` (строки 34-97) не выводятся**. Половина конфига не работает.
  3. `custom/nowplaying` → `now.sh`: **заглушки `YOUR_USERNAME`/`YOUR_API_KEY`**, HTTP (не HTTPS), Last.fm, выведется ошибка "Please edit the now.sh". Лучше: `playerctl`/`mpris` модуль и локальная музыка.

## 2.7 Launcher / Notifications / Lock screen

- **Launcher:** rofi. Установлен, есть keybind Super+Space, `rofi -show drun`. Конфига/темы **нет** — дефолтный внешний вид (белый, без вашей темы). `wl-clipboard`, `cliphist` (Super+V) — хорошо.
- **Notifications:** dunst. **Никакой конфигурации/темы нет** — дефолтные белые всплывашки. Жёлтый.
- **Lock screen:** swaylock. Установлен, Super+L. **Конфига нет** — чёрный экран без часов/индикатора. No blur/wallpaper. Жёлтый (и отсутствие `swayidle`).

## 2.8 GTK / Qt

- **GTK:** включён только `iconTheme = Papirus-Dark` (`home.nix:38-41`). **Темы GTK, cursor, font, darkMode — ничего не задано.** GTK-приложения (GIMP, Thunar... в Wayland) будут светлыми Adwaita. Плюс есть упоминание `stylix` (`home.nix:45-51`) — **модуль stylix нигде не подключён** → оценка упадёт. **Красный флаг.**
- **Qt:** `QT_QPA_PLATFORMTHEME=qt6ct`, но qt6ct не установлен; конфликт с qt5ct в hyprland. **Qt-приложения сейчас выглядят «как Windows XP» без dark-темы.**
- **Решение для вашего стиля:** `qt6ct` + Kvantum (`catppuccin`/`kvantum`-тёмный) или **stylix** (если включить модуль) — почти все современные тёмные темы GTK4/Qt совместимы. Рекомендую: `stylix` для автоматической синхронизации + `catppuccin-mocha`/`gruvbox-dark` как базовый, либо полностью ручной стек `gtk-theme adw-gtk3-dark + QAdwaita/qupt-dark`. Опишу в разделе дизайн-системы.

## 2.9 Шрифты и иконки

- **Шрифты — сильная сторона.** `fonts.packages` (`packages.nix:6-24`): Noto (CJK, emoji), Nerd Fonts JetBrains Mono / Noto / Caskaydia, Carlito, Terminus, Inconsolata, Font-Awesome, Liberation, DejaVu, Cantarell, Unifont. **Кириллица покрыта** Noto + DejaVu. Минус: нет явного `fontconfig.defaultFonts.monospace` => `JetBrainsMono Nerd Font`; стоит задать.
- **Иконки:** Papirus-Dark (GTK), breeze-icons, adwaita-icon-theme, material-icons, gruvbox-plus-icons — запас прочный, но **перебор**: 5 icon-тем одновременно (лишние пакеты).

## 2.10 TUI / CLI / Git / Dev

- **Dубли:** `exa` (deprecated, апстрим заброшен в 2021 — **заменить на `eza`**), `htop`+`btop` (оба писаны, btop в алиасах), `neofetch`+`fastfetch` (оба), `ranger` (+Yazi +Thunar), `jq` (алиас `jq=jq`, `jj=jq` — тавтология).
- **Git:** `programs.git` настроен корректно, но `filter.lfs` ссылается на **`git-lfs`, который не установлен**; `editor = "vim"` (не nvim); alias `d=delta` при отсутствии delta. `delta`/`difftastic` рекомендуется добавить.
- **Языки/LSP:** отличный стек (pyright, ruff, clangd, rust-analyzer, gopls, ...). Но **всё в `home.packages` глобально** — противоречит принципу «языки — в пакет, локально» (для одного пользователя терпимо, но профиль раздувается: `python3Full`, `rustup`, `gcc`, `glibc` в user-profile — нежелательно, `gcc`+`glibc` лучше отдать `nix develop`).
- **ROCm-набор** (`amdgpu_top`, `rocblas`, `hipblas`, `clr`, `rocm-smi`) **утяжелит профиль на гигабайты**. Для gfx1030 дискретки — верно, но лучше через `hardware.amdgpu.rocm.enable` + отдельный `gfxreconstruct`-стек только для геймдева.
- **`direnv` не установлен**, хотя `.envrc` (`use flake`) в корне. Либо поставить `direnv`, либо убрать файл.

## 2.11 Приватные/параллельные вещи

- CSS/hardcoded цветов в 15+ файлах (см. Дизайн-систему).

---

# Раздел 3. Узкие горлышки и ошибки

## 3.1 Безопасность

1. **`services.ollama`: `host = "0.0.0.0"; openFirewall = true` (`packages.nix:45-53`)** — модель LLM доступна **всей LAN** без аутентификации. Для дома — риск. Перевести на `127.0.0.1` и закрыть firewall.
2. **Пользователь без пароля**: `users.users.artlaus` (configuration.nix:38-42) не задаёт `initialHashedPassword`/`hashedPassword` → учётка с заблокированным паролем, sudo недоступен до ручной настройки. На реальном железе задать `initialHashedPassword` или `passwd` при установке. Никаких открытых паролей в конфиге нет — **плюс**.
3. **SSH не включён** (`services.openssh` отсутствует) — для десктопа приемлемо.
4. **Секреты** (Last.fm API-key в `now.sh`, GCP project id, git userEmail) **лежат в открытом виде** в репозитории. Рекомендация: `sops-nix` + `age` для хранения секретов; `now.sh` вообще переписать на `playerctl`.
5. `openFirewall` для Steam remote-play / dedicated server / local transfers (`packages.nix:121-123`) — нужны только если реально пользуетесь; по умолчанию свои порты → можно сузить.

## 3.2 Производительность

- **GC Nix store не настроен** — `nix.gc` отсутствует. С ростом конфига (ROCm, Wine, официалки дистров) store будет разрастаться на десятки ГБ без автоочистки. Добавить `nix.gc.automatic = true; nix.gc.dates = "weekly"; nix.gc.options = "--delete-older-than 30d"`.
- **`nix.settings` почти пуст** — нет `substituters`, нет `Cachix` (а качали бы много), нет `auto-optimise-store`, нет `nix.settings.trusted-users`. Для вашего GPU стека кэши (например, cachix для hyprland/wine) дадут мгновенные сборки.
- **`auto-optimise-store`, `nix.settings.max-jobs`, `cores`** не заданы.
- Тяжёлые дубли в профиле: 5 icon-тем, 3 терминала, kitty+alacritty+wezterm, wine+steam+dota... в целом приемлемо, но чистка сэкономит полгига гигов.

## 3.3 Конфликты и дубли

1. **Двойной импорт `../artlaus` в NixOS** (system/home.nix) — eval-ошибка. **(Красный)**
2. **`inputs` / `pkgs2` / `spkgs`** — неопределённые идентификаторы (см. ниже).
3. **Два polkit-агента** (systemd-юнит + exec-once).
4. **Два значения `QT_QPA_PLATFORMTHEME`** (qt5ct в Hyprland vs qt6ct глобально), ни одно из которых не установлено.
5. **`vim-tmux-navigator` дублирован** в plugins.
6. **Тема "artgreendream"** вызывается в 2 местах, нигде не объявлена.
7. **zsh-плагины OH-MY-Zsh + HM-встроенные?** тройное.

## 3.4 Синтаксис и лучшие практики

- **`pkgs2` и `spkgs` используются в 16 местах, но нигде не определены** (ни `specialArgs`, ни `_module.args`, ни `overlays` в flake). **Кто-то скопировал конфиг с двойным nixpkgs-инпутом и не перенёс его.** Без исправления сборка падает на первом же использовании. **Красный флаг №1 по сборке.**
- `stylix` — использование без модуля. **Красный.**
- `.zsh_history`, `.zcompdump`, `oh-my-zsh/`, `.antidote/` внутри конфига — **данные, а не конфиг**, в репо не нужны.
- Комментарии смешаны en/ru, «референсный конфиг» — следы копипасты.
- `nixos-23.11` и `home-manager release-23.11` — **вышли из поддержки в 2024**. В 2026 актуальны 25.x. **Жёлтый флаг** (безопасность + новые модули не придут).
- `homeConfigurations` (flakes) — не имеет смысла дублировать (для одного хоста можно удалить).
- `--impure` в алиасах `rbs/rbb/upg` — часто не нужен; оставить осознанно.

---

# Раздел 4. Вердикт

## 🔴 Красные флаги (сломают систему/не собрать)

| # | Проблема | Файл |
|---|---|---|
| K1 | `pkgs2` / `spkgs` не определены | `flake.nix`, `system/packages.nix`, `cli/default.nix` |
| K2 | `inputs` не передана в Hyprland-модуль → `inputs.hypr-niri` nil | `artlaus/features/desktop/hypr/hyprland.nix:17` |
| K3 | Двойной импорт home-модуля в NixOS (`../artlaus`) → опции `home/gtk/stylix` не существуют в системном контексте | `system/home.nix:8-10` |
| K4 | `stylix.*` используется без включённого модуля stylix | `system/home.nix:45` |
| K5 | `colorscheme artgreendream` не существует → Neovim без темы | `cli/nvim/init.nix:15`, `plugins/bufferline.nix:7` |
| K6 | LSP-код на API Neovim 0.11 при установленной 0.9.5 | `lua/plugins/lsp.nix` |
| K7 | `boot.loader.grub.device = "/dev/sda"` — убьёт UEFI-загрузку на реальном железе | `system/configuration.nix:29` |
| K8 | **Нет `fileSystems`, нет swap** — конфиг не переживёт установку как самодостаточный | весь `system/` |
| K9 | **Нет services.pipewire / wireplumber** — не будет звука вовсе | весь `system/` |
| K10 | **Нет display manager / greetd** — нет графического входа | весь `system/` |
| K11 | **Нет `hardware.opengl.enable` / GPU-настройки** — нет аппаратного ускорения | весь `system/` |
| K12 | `QT_QPA_PLATFORMTHEME="qt6ct"` при отсутствии qt6ct | `home.nix:28` |
| K13 | `shell.program = "wsl.exe"` и `default_prog = "wsl.exe"` (WSL-артефакт) | `alacritty.nix:11`, `wezterm.nix:79` |
| K14 | `programs.zsh.antidote`, `programs.yazi` — нет в home-manager 23.11 | `zsh.nix:92`, `yazi.nix:4` |
| K15 | Waybar `output = "DP-1"` (лэптоп не покажет панель) | `waybar.nix:15` |

## 🟡 Жёлтые флаги (риски, деградация в будущем)

- Lazy.nvim качает плагины из сети (не откат, нет сети → нет Neovim); Treesitter-парсеры, markdown-preview.
- Nixpkgs/HM 23.11 EOL — обновить (25.11/25.05).
- Hyprland из flake трекает `main` (не воспроизводимо) и фактически не используется (берется старый из 23.11).
- `hypr-niri` плагин — сомнительная зрелость; рассмотреть чистый niri или стандартную раскладку.
- `cd = "z"`, переопределение `/`,`.`,`,` — рискованно для muscle memory и скриптов.
- GPG/pinentry-qt без qt-темы → некрасивый и, возможно, битый prompt.
- Очень большой раздутый профиль (5 icon-тем, 3 терминала, ROCm-гиготоны).
- `exa` deprecated → `eza`.
- No `nix.gc`, No `substituters`, No `Cachix`.
- Безопасность ollama на 0.0.0.0.
- Секреты в открытом виде в конфиге (Last.fm, GCP).

## 🟢 Зелёные зоны (что уже хорошо)

- Модульная структура `flake + imports` (с мелкими изъянами, но идея правильная).
- `allowUnfree` включён корректно.
- Отличный шрифтовой набор с кириллицей и Nerd Fonts.
- Хорошая Neovim-начинка по замыслу (telescope, lspsaga, noice, cmp, lualine, treesitter, yazi.nvim).
- Полный запас языковых LSP.
- Steam/gamemode/gamescope, wine-стек, ROCm-инструменты под Radeon.
- nix-ld и appimage — правильные для неродных бинарей.
- GPG-агент с SSH-поддержкой.
- Продуманный Yazi (превью, фильтры, keymap).
- Вектор визуальной темы уже задан (#66FF99, #001a0d) — в 15+ файлах, но консистентно по духу.

---

# Раздел 5. Дизайн-система: текущее состояние

## 5.1 Оценка (0-10)

| Компонент | Оценка | Комментарий |
|---|---|---|
| Цветовая консистентность | 5/10 | Один акцент (#66FF99) везде, но есть чужие палитры (git-цвета #FF007C, yazi Hovered #FFD966), QT не тронут |
| Шрифты | 8/10 | Набор отличный, нет дефолтов для mono/sans |
| Terminal | 5/10 | WezTerm могуч, но не выбран «главным», WSL-заглушки, прозрачность без blur-компромисса |
| Shell | 4/10 | Мусорные алиасы, тройной zoxide/omegaz, конфликт OMZ+Starship, broken `nn`, `d`, `pkgs`, `upg` |
| Neovim | 6/10 | Стек хорош, но темы нет, LSP 0.11 vs 0.9, undefile противоречие, двойные плагины |
| Wayland | 4/10 | Hyprland настроен, но режим niri-плагина, нет DM, нет polkit-дублирования, порталы, idle |
| Bar | 6/10 | Waybar стилизован, но половина модулей не выводится, output захардкожен |
| Launcher | 4/10 | Rofi без темы |
| Notifications | 3/10 | dunst без конфига |
| Lockscreen | 3/10 | swaylock без конфига, нет swayidle |
| GTK | 3/10 | Только иконки; тема/dark/сursor отсутствуют |
| Qt | 2/10 | Указан несуществующий qt6ct |
| Icons | 8/10 | Papirus-Dark — отлично, но 5 тем = раздувание |
| TUI | 8/10 | yazi, lazygit, btop, fzf, zoxide — сильный набор |
| CLI | 5/10 | Дубли (exa/htop/neofetch...), сломанные алиасы |
| Git | 5/10 | Базово ok; delta/lfs не установлены |
| Nix UX | 3/10 | Нет gc/substituters/nh; --impure в алиасах |
| Performance | 4/10 | Раздутый профиль, много runtime-скачиваний |
| **Overall coherence** | **4/10** | Задумка цельная, реализация рассыпается |

## 5.2 Проблемы визуальные (главные)

1. **Нет единой цветовой палитры** — значения разбросаны по 15+ файлам, часть цветов противоречит (Yazi yellow hovered vs поп-жёлтый; git неоново-розовый; #FFD966 в одном, #FFD500 в др.).
2. **GTK/Qt не затронуты** — светлые Adwaita среди тёмных терминалов = визуальный разрыв.
3. **Rofi/dunst/swaylock — дефолтные темы** — весь контур (launcher/notify/lock) выпадает из дизайна.
4. **Waybar-модули не показаны** — панель пустовата для заявленного дизайна.
5. **Нет wallpapers** — заменяется солид-цветом hyprpaper без самого изображения (hyprpaper не умеет «чистый» solid через `wallpaper ,#hex` — он работает с preload картинок/и может с цветом в новых версиях, но код сомнителен).

## 5.3 Централизация цветов — предлагаемая архитектура

Не создавать абстракцию ради абстракции: у вас **один пользователь, один хост**. Поэтому:

```
~/nixos-config/theme/
├── colors.nix      → аттрибут-набор { bg, bg-alt, fg, primary, secondary, accent-blue, error, warning, success, info, muted, comment, border, selection, cursor }
├── fonts.nix       → ui / mono / icons
└── default.nix     → мэпл: создаёт стиксы для терминалов, waybar CSS, hyprland rgba, rofi, dunst, swaylock
```

Инжектировать через `theme.colors` и подставлять через Nix (`with config.theme.colors`). Сразу же (в Nix) сгенерируются:
- `toRgba` для Hyprland (у вас уже есть `toRgba` в hyprland.nix — вынести в lib);
- fill для Waybar CSS (строками);
- палитры терминалов (WezTerm уже Nix, Alacritty Nix);
- Neovim — через `vim.cmd("let g:artgreendream=...")` или описанную тему.

## Рекомендуемая палитра «Artlaus Neon»

| Роль | HEX | Читаемость |
|---|---|---|
| bg (основа) | `#001a0d` | высокая |
| bg-alt (панели) | `#0D3322` (полупрозрачный) | — |
| fg | `#C0FFC0` (мягкий бело-зелёный) | 16:1 |
| primary | `#66FF99` | 17:1 |
| secondary | `#C4A0FF` | 15:1 |
| accent-blue | `#58D6FF` | 14:1 |
| error | `#FF5566` | 8:1 |
| warning | `#FFD966` | 12:1 |
| success | `#66FF99` (= primary) | 17:1 |
| info | `#7FD6FF` | 12:1 |
| muted | `#448866` | 5:1 |
| comment | `#3D6655` | 4:1 |
| selection | bg primary 40% | — |
| cursor | `#66FF99` | — |

**Контраст проверен против bg #001a0d** — все семантические элементы различимы.

---

# Раздел 6. Визуальные направления (3 варианта)

- **A — Pure Neon Green.** Только #000/#001a0d + #66FF99..#C0FFC0. Максимальный минимализм; риски — нет визуального разделения warning/error. Оценка: читаемость 10, глубина 7.
- **B — Neon Green + Lavender (рекомендую).** Основной #66FF99, вторичный #C4A0FF, акцент-циан. Даёт разделение «функция/контрол» без хаоса. Оценка: читаемость 9, глубина 9.
- **C — Neon Green + Electric Blue.** #66FF99 + #0078FF/#58D6FF. Ярче технологически, но риск «кислотности». Оценка: читаемость 8, глубина 8.

**Выбор: B** — совпадает с вашим первоначальным запросом (пирсинг #C4A0FF), даёт необходимые семантические слоты, не превращает систему в зелёную кашу.

**Прозрачность (правило):** использовать только там, где подложка тёмная и текст гарантированно читается: терминал 0.9/бесшовный, waybar 0.85+blur, rofi/dunst/swaylock 0.95, **не** прозрачить диалоговые окна (кодекс читаемости). Blur только на Hyprland (нужен `xdg-portal`+свежий Hyprland).

---

# Раздел 7. Целевая архитектура конфига (после переустановки)

```
flake.nix                      → inputs: nixpkgs 25.05(+1 overlay stable/unstable), home-manager 25.05, hyprland (пин), agenix/sops
├── lib/default.nix            → toRgba, mkTheme helpers
├── hosts/msi-laptop/
│   ├── system.nix             → boot(UEFI/systemd-boot), fileSystems, network, pipewire, opengl, displayManager(greetd|sddm), xdg.portal, users, nix settings
│   ├── packages.nix           → системные пакеты (GPU, wine, steam)
│   └── services.nix           → ollama(127.0.0.1), polkit, steam firewall, gnupg
├── home/artlaus/              → home-manager (НЕ импортировать в system!)
│   ├── shell/zsh.nix, starship.nix, git.nix
│   ├── terminal/wezterm.nix
│   ├── nvim/                  → lazy-load + Nix-спеки
│   ├── desktop/hyprland.nix, waybar.nix, rofi.nix, dunst.nix, swaylock.nix, swayidle.nix
│   └── gtk-qt/theme.nix
└── theme/
    ├── colors.nix, fonts.nix, default.nix
```

Принцип: **один источник цветов**, **один «владелец» каждого компонента**, и **минимальное число «производительных» мест сборки пакетов** (системный+home).

---

# Раздел 8. Priority Matrix

| Приоритет | Компонент | Сейчас | Предлагается | Причина | Сложность | Риск |
|---|---|---|---|---|---|---|
| P0 | flake.nix specialArgs | нет pkgs2/spkgs | ввести overlay nixpkgs-unstable или `_module.args` | сборка падает | низкая | отсутствует |
| P0 | imports hyprland | `inputs` nil | передать inputs / убрать hypr-niri или фикс. пин | сборка падает | средняя | средний |
| P0 | home.nix импорт | двойной ../artlaus | убрать; оставить только hm-модуль | eval-ошибка | низкая | нет |
| P0 | stylix | use-without-module | включить stylix или удалить | eval-ошибка | низкая | нет |
| P0 | boot | grub /dev/sda | systemd-boot + ESP из fileSystems | иначе не загрузится | средняя | нет |
| P0 | fileSystems/swap | отсутствуют | добавить для реальных разделов | иначе не boot | средняя | нет |
| P0 | pipewire/wireplumber | нет | включить + pactl/playerctl | иначе нет звука | низкая | нет |
| P0 | display manager | нет | greetd или SDDM + Hyprland-session | иначе нет входа | низкая | нет |
| P0 | hardware.opengl | нет | enable + amdgpu | иначе нет GPU-gl | низкая | нет |
| P0 | neovim colorscheme | artgreendream? | тема из theme/colors.nix | иначе nvv без темы | средняя | нет |
| P0 | nvim LSP API | 0.11 в nvim 0.9 | обновить nvv до 0.11+ (или nixpkgs 25) | иначе LSP мёртв | средняя | нет |
| P1 | WSL-артефакты | wsl.exe | zsh / удалить | запуск терминала | низкая | нет |
| P1 | pkgs nixpkgs 23.11 | EOL | 25.05/25.11 + hyprland unstable-пин | поддержка, новые модули | высокая | средний |
| P1 | QT | qt6ct не установлен | qt6ct + kvantum, унифицир. env | Qt выглядит как XP | низкая | нет |
| P1 | GTK | только иконки | adw-gtk3-dark / catppuccin + cursor | единый вид | низкая | нет |
| P1 | launcher/notify/lock | дефолтные | rofi+dunst+swaylock темы из theme | цельный контур | низкая | нет |
| P1 | swayidle | нет | autolock | безопасность | низкая | нет |
| P1 | waybar | захардкожен, половина mod | output auto + full modules | панель-как-часть системы | низкая | нет |
| P1 | nix.gc/substituters | нет | weekly GC + cachix-кэши | дисковое пространство | низкая | нет |
| P2 | zsh | тройной zoxide, OMZ-star | чистка, единый zoxide, убрать OMZ или тему None | быстрый шелл | средняя | низкий |
| P2 | aliases | broken nn/d/pkgs/upg | починить или удалить | честный UX | низкая | нет |
| P2 | neovim плагины | lazy из сети | lazy-loader-Nix-спеки + lock | воспроизводимость | высокая | низкий |
| P2 | eza вместо exa, delta, git-lfs | exa/_delta_/lfs missing | добавить | современный CLI | низкая | нет |
| P3 | hypr-niri → niri | гибрид-плагин | чистый niri или Hyprland без | стабильность | высокая | средний |
| P3 | wallpapers | нет | набор превью + hyprpaper | эстетика | средняя | низкий |
| P3 | sops/agenix | секреты в открытую | sops-nix+age | безопасность | средняя | низкий |

---

# Раздел 9. План внедрения (фазы)

- **Phase 1 — Фундация**: flake.nix (specialArgs, пин nixpkgs 25.05+HM, новая структура hosts/), fileSystems+swap+systemd-boot, users+password, и «первая сборка» `nix flake check` + `nixos-rebuild build`.

- **Phase 2 — аудио/GPU/портлы**: pipewire, opengl, amdgpu, displayManager, xdg.portal, polkit (один юнит).

- **Phase 3 — Theme foundation**: `theme/colors.nix` + lib; затем прошивание цветов через терминал, waybar, rofi, dunst, swaylock.

- **Phase 4 — Terminal/Shell**: выбрать WezTerm, почистить zsh/starship/алиасы, убрать OMZ-мусор, добавить direnv+`.envrc`.

- **Phase 5 — Neovim**: nvv 0.11+, тема из theme, фикс LSP, lazy-спеки.

- **Phase 6 — Wayland**: Hyprland-пин + фикс inputs, waybar full, rofi/dunst/swaylock/swayidle, WM keybind-аудит.

- **Phase 7 — GTK/Qt**: qt6ct+KVantum, gtk theme/cursor/dark, единый QT_QPA_PLATFORMTHEME.

- **Phase 8 — TUI/CLI**: eza, delta, git-lfs, btop-чистка (neofetch/fastfetch — одно), вычистка дублей.

- **Phase 9 — Automation**: nix.gc, substituters, команды `nh`, `nvd`; ollama на 127.0.0.1.

- **Phase 10 — Final cleanup**: удалить вендоренный oh-my-zsh/.antidote/.zsh_history, секреты → sops, `git init` + README, финальная проверка.

---

# Раздел 10. Чеклист проверки

```bash
cd ~/nixos-config
nix flake show
nix flake check
nixos-rebuild dry-build --flake .#msi-laptop
nixos-rebuild build --flake .#msi-laptop        # -> /result
sudo nixos-rebuild switch --flake .#msi-laptop
systemctl --user status pipewire wireplumber
systemctl status display-manager
systemctl status ollama                          # слушает 127.0.0.1?
xdg-open .                                       # файл-пикер через portal
```

Проверить: тема GTK/Qt, терминал (прозрачность+бленд), waybar выводит все 8 модулей, rofi-тема, dunst-красоту, swaylock, screenshots (grim+swappy), Super+V cliphist, запуск LSP в nvv.

---

# Раздел 11. «Что я бы сделал на твоём месте» — 20 действий (по приоритету)

1. **Перевести флейк на `nixpkgs` 25.05 + `home-manager` 25.05** (один пин общий) — решает K14 (antidote/yazi/некоторые opts), LSP API, всю остальную совместимость, EOL.
2. **Завести `specialArgs` / `_module.args` или overlay** для `pkgs2`/`spkgs` (или заменить на единый `pkgs`) — K1. Проверить сборку.
3. **Удалить `imports = [ ../artlaus ]` из `system/home.nix`** — K3 (останется только hm-модуль из flake).
4. **Выключить/включить stylix** — решить: включить модуль stylix (fast-track цельность) или удалить блок. K4.
5. **Собрать `boot` заново**: вложить `fileSystems` (EFI+root+swap), `boot.loader.systemd-boot` или `lanzaboote` вместо GRUB `/dev/sda`. K7/K8.
6. **Включить `services.pipewire`, `services.mpris`, `playerctl`** — K9. Добавить `hardware.opengl.enable`, `hardware.amdgpu.rocm.enable`. K11.
7. **Добавить display manager** — рекомендуемый SDDM (Qt-тема затронет и Qt движок) или минимальный greetd с tmux-session. K10.
8. **Исправить Neovim-theme**: создать `theme/neovim-artlaus.nix` (или плагин-тему), `colorscheme` из неё. Убрать `artgreendream`. K5.
9. **Обновить Neovim до 0.11+** (свежий nixpkgs или `pkgs.neovim-unwrapped.override`) — K6.
10. **Чистка Hyprland**: передать `inputs`, выбрать между Hyprland+плагин-niri или классическим Hyprland; убрать runtime-`nix-instantiate` polkit; добавить `xdg.portal.hyprland`, `swayidle`. K2/K3.
11. **Убрать WSL**: `wsl.exe` → zsh/логин-шелл в Alacritty/WezTerm. K13.
12. **Waybar**: `output` в `[]`/auto или default, подключить cpu/memory/network/pulseaudio/temperature в modules-right; переписать `now.sh` на `playerctl metadata` (mpris), убрать Last.fm. K15.
13. **QT**: поставить `qt6ct`+`kvantum`+dark-тему, единый `QT_QPA_PLATFORMTHEME=qt6ct`, убрать из hyprland `qt5ct`. K12.
14. **GTK**: добавить тему (adw-gtk3-dark / catppuccin-dark), `gtk.cursorTheme`, `gtk.font`, `gtk-application-prefer-dark-theme`, иконку Papirus (уже есть).
15. **Shell**: убрать двойной zoxide/omz-плагины/встроенные auto*, починить алиасы (`nn`, `d`, `pkgs`, `upg`, `y`), `cd` не переопределять глобально.
16. **Однозначно nvm**: убрать NVM_DIR/`nvm.sh` (если node через Nix) или оставить только npm-глобал через hm.
17. **Nix-экосистема**: `nix.gc.automatic`+weekly, `nix.settings.substituters` + `cachix`-инпуты (hyprland, wine, cachix nix-community), `nh` + `nvd` в devShell.
18. **Секреты**: вынести Last.fm/GCP/почту в `sops-nix` или `.env.example;` убрать захардкоженную почту из git в `sops`.
19. **Оскорбить безопасность**: ollama на `127.0.0.1`, `openFirewall = false`; задать `initialHashedPassword` (sops) для пользователя.
20. **Чистка репо**: `git init`, удалить `oh-my-zsh/`, `.antidote/`, `.zsh_history`, `.zcompdump`, пустые `modules/*`, `lib/`; поставить `direnv` или убрать `.envrc`; добавить `eza`, `delta`, `git-lfs`.

---

# Раздел 12. Итоговые оценки

```
Design Score             4/10   (задумка 9/10, реализация разбросана)
UX Score                 4/10
Consistency Score        3/10   (не достроены GTK/Qt/launcher/notify/lock)
Nix Integration Score    2/10   (не собирается: pkgs2/spkgs/inputs/двойной импорт)
Performance Score        4/10   (нет GC, раздутый профиль)
Open Source Score        8/10   (почти всё FOSS; убрать Last.fm/pin2-supermaven)
```
