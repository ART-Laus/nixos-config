# Архитектурное предложение: модульный конструктор NixOS

*Статус: утверждено (flat + features) · Дата: 15.09.2026 · Обновлено: 15.09.2026 · Автор: Muse Spark · Основано на аудите `about.md`*
*Решения: плоская структура · `theme/` в корне · `greetd` · `Lazy.nvim` · `features/` сохраняется*

> Цель — превратить `~/nixos-config` из WSL-миграции в **конструктор из независимых кубиков** с очевидной ответственностью, слабой связанностью и одним источником темы.

---

## 1. Принципы (согласованы с ТЗ)

| Приоритет | Принцип | Как применяем |
|---|---|---|
| 1 | Понятность | Дерево = документация. Имя файла = ответственность. |
| 2 | Модульность | Один модуль — одна логическая роль. |
| 3 | Независимость | Feature flag → вкл/выкл без каскадных поломок. |
| 4 | Воспроизводимость | Nix владеет версиями/бинарниками, Lua — поведением. |
| 5 | Безопасность | Секреты в sops, минимум openFirewall. |
| 6 | Производительность | Нет лишних демонов/прозрачности ради прозрачности. |
| 7-10 | Консистентность/Удобство/Красота/Эксперименты | Через централизованную Theme System. |

**Что НЕ делаем:** `module factory / feature registry / configuration provider` ради `programs.git.enable = true`. Используем нативный NixOS module system (`options.*.enable = mkEnableOption`).

---

## 2. Proposed Architecture — дерево файлов (утверждено: FLAT + features)

### 2.1 Полное дерево (целевое — плоское, с сохранением `features/`)

```text
flake.nix                          # единственная точка входа, inputs + specialArgs
flake.lock
.envrc                             # → direnv (требует pkgs.direnv)
README.md
about.md                           # аудит
docs/
├── architecture.md                # ← этот файл
├── neovim.md                      # исследование Neovim (выбор: Lazy.nvim)
└── devlog.md                      # индекс девлога (Obsidian)
└── devlog/                        # каждая запись — отдельная заметка
    ├── 2026-09-14-audit.md
    ├── 2026-09-15-architecture.md
    └── 2026-09-15-neovim.md

hosts/
└── msi-laptop/                    # один хост = одна папка (готовность ко второму хосту)
    ├── default.nix                # nixosSystem: импортирует system + home
    ├── hardware-configuration.nix # сгенерирован nixos-generate-config (fileSystems, swap, boot)
    └── disko.nix                  # (опционально) декларативная разметка диска

theme/                             # ← ЕДИНСТВЕННЫЙ источник темы (утверждено: в корне)
├── colors.nix                     # палитра Artlaus Neon
├── fonts.nix                      # ui / mono / nerd — имена шрифтов
└── default.nix                    # хелперы: toRgba, mkWaybarCss (опционально)

lib/
└── theme.nix                      # чистые функции: hexToRgba, mkAlpha

system/                            # ← отвечает за МАШИНУ (NixOS) — ПЛОСКО
├── nix.nix                        # nix.settings, gc, substituters, trusted-users
├── boot-hardware.nix              # boot (systemd-boot) + graphics/amdgpu + audio/pipewire + bluetooth + power + firmware
├── networking-security.nix        # networkmanager + firewall + gpg + polkit (один!) + sops
├── services.nix                   # greetd (утверждено) + portals (xdg-desktop-portal-hyprland) + ollama (127.0.0.1)
├── gaming.nix                     # steam + wine + gamemode + gamescope (флаг features.gaming)
├── virtualization.nix             # docker / podman (флаг features.virtualization)
└── packages.nix                   # остаток <30 строк — то, что не раскладывается

home/                              # ← отвечает за ПОЛЬЗОВАТЕЛЯ (Home Manager) — ПЛОСКО + features/
├── default.nix                    # home-manager.users.artlaus: импортирует features/* + theme
├── shell.nix                      # zsh + starship + aliases (один файл — одна роль: shell)
├── desktop.nix                    # hyprland + hyprpaper + waybar + rofi + dunst + swaylock + swayidle + clipboard + screenshots
├── cli.nix                        # git (delta/lfs) + tools (eza/bat/ripgrep/fzf/btop) + yazi + tmux
├── terminal.nix                   # wezterm (главный, greetd-совместимый) — kitty/alacritty опционально
├── development.nix                # languages (direnv, devShells) + containers (lazydocker)
├── media.nix                      # mpv + obs + strawberry/spotify (опционально)
├── gaming.nix                     # mangohud + protonup-qt (home-часть, флаг features.gaming)
├── browsers.nix                   # firefox + chromium + librewolf
├── gtk-qt.nix                     # gtk + qt6ct + kvantum + cursor + icons (единый тёмный стиль из theme/)
└── features/                      # ← СОХРАНЯЕМ как пространство для роста (ваш запрос)
    ├── README.md                  # объясняет: когда выносить из плоских файлов в features/
    └── neovim/                    # единственный feature, который уже заслуживает папку (сложный)
        ├── default.nix            # feature flag features.neovim.enable + imports
        ├── neovim.nix             # programs.neovim + xdg.configFile."nvim" → ./nvim
        └── nvim/                  # ← ЧИСТЫЙ Lua (Lazy.nvim, утверждён)
            ├── init.lua
            ├── lazy-lock.json     # коммитится — детерминизм
            └── lua/
                ├── core/          # options, keymaps, autocmds
                ├── plugins/       # telescope.lua, lsp.lua, ... (один файл = один плагин)
                ├── lsp/           # lsp config (использует Nix-бинарники)
                └── ui/            # lualine, theme.lua (генерируется из theme/colors.nix)

scripts/
├── rofi-media.nix                 # ваш rofi-media-scripts (оставить)
└── media/                         # rofi-image/video/audio.sh
```

**Почему плоско + `features/` (ваш выбор):**

- **Плоско** — для одного хоста `system/` из 6 файлов и `home/` из 8 файлов **читается за 10 секунд**. Иерархия `system/core + system/hardware + system/services` была бы избыточна сейчас (нарушает принцип «не впадать в противоположную крайность»).
- **`features/` сохраняется** — как **инкубатор**. Правило: пока `desktop.nix` < ~200 строк — живёт плоско. Как только `desktop.nix` разрастётся (например, waybar + rofi + dunst требуют своих тем) — **расщепляем**: `home/desktop.nix` → `home/features/desktop/{hyprland.nix, waybar.nix, rofi.nix, dunst.nix}`. Аналогично `gaming.nix` → `features/gaming/`. Это даёт **эволюционный путь** без переписывания сейчас.
- `neovim/` уже в `features/` — потому что это единственный компонент, который **уже** сложный (30 плагинов, Lua-дерево). Ему нужна папка сейчас.
- `theme/` в корне (утверждено) — доступен и `system` (greetd, grub) и `home` (waybar, nvim) через `specialArgs.theme` без относительных `../../../theme`.
- `hosts/msi-laptop/` — готовность ко второму хосту без копипасты (`hosts/second-laptop/default.nix` импортирует те же `system/` + `home/`).

**Чего НЕ должно быть в каждой папке:**

| Папка | Не должно содержать |
|---|---|
| `system/` | `programs.zsh`, `gtk.*`, `waybar`, `nvim`, `aliases` |
| `home/` | `boot.loader`, `fileSystems`, `services.pipewire`, `hardware.*` |
| `hosts/` | логики (только импорты + hardware-configuration) |
| `theme/` | логики сервисов, только данные (цвета/шрифты) |
| `lib/` | state, только чистые функции |
| `home/features/` | плоских однофайловых фич (они живут в `home/*.nix` пока маленькие) |

**Правило расщепления (когда выносить из `home/*.nix` в `home/features/`):**

```text
home/desktop.nix  < 200 строк  →  остаётся плоским
home/desktop.nix  > 200 строк  →  расщепить на home/features/desktop/{*.nix}
home/gaming.nix   всегда маленький  →  может остаться плоским, но если добавите 5 gaming-инструментов → в features/
```

---

### 2.2 Эволюция (когда плоское станет иерархическим)

Текущее (2026-09) — плоско. Будущее (когда 2-й хост или 100+ пакетов) — иерархия безболезненно:

```text
# Сейчас:
home/desktop.nix
# Позже (автоматически, без breaking change):
home/desktop.nix  →  home/features/desktop/
                     ├── compositor.nix
                     ├── bar.nix
                     ├── launcher.nix
                     └── lockscreen.nix
# home/default.nix меняет один импорт:
#   imports = [ ./desktop.nix ];
# на
#   imports = [ ./features/desktop ];
```

Никакого Enterprise Java — просто `imports`.

---

## 3. Feature Flags — как включать/выключать кубики

### 3.1 Нативный NixOS-подход (утверждено)

Каждый крупный блок объявляет опцию:

```nix
# home/gaming.nix
{ lib, config, pkgs, ... }: {
  options.features.gaming.enable = lib.mkEnableOption "gaming tools (mangohud, protonup-qt)";

  config = lib.mkIf config.features.gaming.enable {
    home.packages = with pkgs; [ mangohud protonup-qt ];
  };
}
```

Аналогично для system-части:

```nix
# system/gaming.nix
{ lib, config, ... }: {
  options.features.gaming.enable = lib.mkEnableOption "gaming (system)";

  config = lib.mkIf config.features.gaming.enable {
    programs.steam.enable = true;
    programs.gamemode.enable = true;
  };
}
```

**Важно:** опции `features.*` объявляются ОДИН раз (в `home/default.nix` или `lib/features.nix`), прокидываются в system через `specialArgs`.

### 3.2 Где хранить переключатели

```nix
# hosts/msi-laptop/default.nix
{
  features = {
    cli.enable = true;            # всегда
    desktop.enable = true;        # всегда
    development.enable = true;
    gaming.enable = true;         # → false = нет steam/wine/mangohud (и в system, и в home)
    multimedia.enable = true;
    virtualization.docker.enable = false;
    ai.ollama.enable = true;
    neovim.enable = true;         # Lazy.nvim (утверждено)
  };
}
```

Один файл — одно место правды. `gaming.enable = false` → ни `system/gaming.nix`, ни `home/gaming.nix` не активируются.

---

## 4. Dependency Graph — кто от кого зависит

### 4.1 Допустимые зависимости

```text
                    ┌─────────────────┐
                    │   lib/theme.nix │  (чистые функции, ни от чего не зависит)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  theme/  │   │  System  │   │   Home   │
        │  colors  │◄──│  (nix,   │   │  (shell, │
        │  fonts   │   │  boot-   │   │  gtk-qt, │
        └────┬─────┘   │ hardware)│   │  theme)  │
             │         └────┬─────┘   └────┬─────┘
             │              │              │
     ┌───────┼───────┐      │      ┌───────┼────────┐
     ▼       ▼       ▼      ▼      ▼       ▼        ▼
   ┌────┐ ┌────┐ ┌──────┐ ┌─────┐ ┌────┐ ┌──────┐ ┌─────┐
   │CLI │ │Desk│ │ Dev  │ │Gaming│ │Media│ │Net │ │Sec  │
   └──┬─┘ └──┬─┘ └──┬───┘ └─────┘ └────┘ └──────┘ └─────┘
      │      │      │
      ▼      ▼      ▼
   ┌──────────────────┐
   │  Neovim (Lazy)   │
   │  внутри CLI, но  │
   │  может жить      │
   │  отдельно        │
   └──────────────────┘
```

**Правила:**

- ✅ `theme/ → всё` (цвета используются везде, greetd тоже)
- ✅ `CLI → Neovim` (Neovim зависит от shell/tools, но не наоборот)
- ✅ `Desktop → theme` (waybar/rofi берут цвета)
- ❌ `Desktop ↛ CLI` (отключение Neovim не ломает Hyprland)
- ❌ `CLI ↛ Desktop` (CLI работает headless без Hyprland)
- ❌ Циклы (`A → B → A`)

### 4.2 Текущие скрытые зависимости (из аудита)

| Зависимость | Проблема |
|---|---|
| `system/home.nix` импортирует `../artlaus` | System зависит от Home — ломает сборку |
| `hyprland.nix` использует `inputs.hypr-niri` без `inputs` | Требует flake inputs, но не декларирует |
| `yazi.nix` → `config.home.sessionVariables.EDITOR` | Хрупкая, нужен fallback |
| `zsh.nix` → `oh-my-zsh` + `antidote` + `zoxide` тройной | Три источника одного функционала |
| `packages.nix` → `pkgs2`/`spkgs` | Требует specialArgs |

**Фикс:** каждая зависимость — **явная** через `specialArgs`, `imports`, или `assert`.

---

## 5. Feature Matrix (обновлено: greetd + Lazy)

| Feature | Вкл/Выкл | Зависимости | System / Home | Файлы (целевые) | Примечание |
|---|---|---|---|---|---|
| **Core: Theme** | всегда | — | Оба (`specialArgs.theme`) | `theme/colors.nix`, `theme/fonts.nix` | Источник правды |
| **Core: Nix** | всегда | — | System | `system/nix.nix` | gc, substituters |
| **System: Boot+HW** | всегда | — | System | `system/boot-hardware.nix` | systemd-boot + amdgpu + pipewire + bluetooth |
| **System: Net+Sec** | всегда | — | System | `system/networking-security.nix` | NM + firewall + gpg + polkit + sops |
| **System: Services** | всегда | HW | System | `system/services.nix` | **greetd** + portals + ollama (127.0.0.1) |
| **CLI: Shell** | `features.cli` | Theme | Home | `home/shell.nix` | zsh + starship |
| **CLI: Terminal** | `features.cli` | Shell, Theme | Home | `home/terminal.nix` | **WezTerm** |
| **CLI: Tools** | `features.cli` | — | Home | `home/cli.nix` | git+delta/lfs, eza, ripgrep, yazi, tmux |
| **CLI: Neovim** | `features.neovim` | CLI | Home | `home/features/neovim/` | **Lazy.nvim** + `lazy-lock.json` |
| **Desktop** | `features.desktop` | Theme, HW | Оба | `home/desktop.nix` | Hyprland + waybar + rofi + dunst + swaylock/idle |
| **Desktop: GTK/Qt** | `features.desktop` | Theme | Home | `home/gtk-qt.nix` | qt6ct+kvantum, единый стиль |
| **Dev** | `features.development` | CLI | Home | `home/development.nix` | direnv + devShells |
| **Gaming** | `features.gaming` | HW, Audio | Оба | `system/gaming.nix` + `home/features/gaming/` | Steam only (mangohud/protonup удалены) |
| **Media** | `features.multimedia` | Audio | Home | `home/media.nix` | mpv, obs |
| **Browsers** | всегда | — | Home | `home/browsers.nix` | firefox, chromium |

---

## 6. Разбор: монолиты, дубли, скрытые зависимости

| Категория | Пример | Проблема |
|---|---|---|
| **Монолит** | `system/packages.nix` (266 строк) | Шрифты + ollama + steam в одном файле |
| **Смешанная ответственность** | `artlaus/features/cli/default.nix` (196 строк) | Терминалы + языки + LSP в одном |
| **Дубли** | `exa`/`btop`/`neofetch`/`ranger` | Раздувает профиль |
| **Скрытая зависимость** | `system/home.nix` → `../artlaus` | System→Home |
| **Разорванная логика** | `QT_QPA_PLATFORMTHEME` в двух местах | Конфликт qt5ct/qt6ct |
| **Мёртвый код** | `modules/*`, `lib/*` пустые | Шум |

### Migration Plan (Было → Станет → Почему)

| Было | Станет | Почему |
|---|---|---|
| `system/packages.nix` (266 строк) | `system/boot-hardware.nix` + `system/gaming.nix` + `system/services.nix` + `packages.nix` (<30) | Один флаг `gaming.enable` выключает Steam без правки шрифтов |
| `artlaus/features/cli/default.nix` (196) | `home/shell.nix` + `home/cli.nix` + `home/development.nix` | CLI работает без Rust/Python |
| `system/home.nix` → `../artlaus` | Удалить файл. Home только через `hosts/.../default.nix` | Убирает цикл System→Home |
| `pkgs2`/`spkgs` | `flake.nix: specialArgs = { inherit inputs; }` | Явная зависимость |
| `hyprland.nix: inputs.hypr-niri` | `hyprland.nix = { inputs, ... }:` + пин | Честная декларация |
| `#66FF99` в 15 файлах | `theme/colors.nix` → `specialArgs.theme` | Один источник |
| 3 терминала с WSL | `home/terminal.nix` (WezTerm) | Убирает дубль |
| `boot.loader.grub /dev/sda` | `hosts/.../hardware-configuration.nix` + `systemd-boot` | UEFI |
| Нет `pipewire`/`greetd` | `system/boot-hardware.nix` + `system/services.nix` (greetd) | Звук + графический вход |
| `now.sh` Last.fm | `home/desktop.nix` → `mpris` | Без секретов |
| `oh-my-zsh/` 18М вендор | Удалить, брать из `pkgs` | Данные ≠ конфиг |

---

## 7. Централизация Theme

```nix
# theme/colors.nix
{
  bg = "#001a0d";
  bgAlt = "#0D3322";
  fg = "#C0FFC0";
  primary = "#66FF99";
  secondary = "#C4A0FF";
  accentBlue = "#58D6FF";
  error = "#FF5566";
  warning = "#FFD966";
  muted = "#448866";
  comment = "#3D6655";
}
```

```nix
# flake.nix
let theme = import ./theme/colors.nix;
in {
  nixosConfigurations.msi-laptop = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs theme; };
    modules = [ ./hosts/msi-laptop/default.nix ];
  };
}
# любой модуль: { theme, ... }: { background = theme.primary; }
```

Для Neovim (Lazy): `home/features/neovim/nvim/lua/ui/theme.lua` генерируется из `theme/colors.nix` (см. `docs/neovim.md`).

---

## 8. Практичность

| Задача | Сейчас | После |
|---|---|---|
| «Не хочу Docker» | `grep docker` по репо | `features.virtualization.docker.enable = false` |
| «Заменить Waybar» | Правлю 3 файла, боюсь сломать | Удаляю `waybar` секцию в `home/desktop.nix` |
| «Поменять Neovim» | 20 файлов + home.nix | `home/features/neovim/` — один вход |
| «Поменять тему» | `grep #66FF99` | `theme/colors.nix` |
| «Дебажить звук» | Ищу среди 266 строк | `system/boot-hardware.nix` |
| «Второй хост» | Копипаста | `hosts/second/default.nix` |

---

## 9. Нужна ли максимальная модульность?

**Да, но «достаточная», не «максимальная».** Для 50+ файлов и одного хоста плоская структура с `features/neovim` — оптимум. Флаги — только для отключаемого (`gaming`, `virtualization`, `neovim`), `core` — всегда включён. Не пишите `mkFeature` фабрику ради DRY — `mkEnableOption` достаточно.

---

## 10. Следующие шаги (обновлено)

- [x] Утверждено: плоско + `features/` + `theme/` в корне + `greetd` + `Lazy.nvim`
- [x] Обновить `docs/neovim.md` (Lazy) и `docs/devlog.md` (Obsidian)
- [x] Phase 1: `hosts/msi-laptop/` + `system/nix.nix` + `theme/colors.nix` + `flake.nix` (specialArgs, 25.05)
- [x] Phase 2: удаление `artlaus/`, `system/home.nix`, `system/configuration.nix`; фикс devShell; `nix flake check` OK
- [ ] Phase 3: `theme/` прошивка цветов через все компоненты (waybar CSS, hyprland rgba, rofi, dunst, swaylock, nvim theme.lua)

*Вопросы — в `docs/devlog.md` или PR к этому файлу.*
