---
title: "Automation Layer — Этап 3: Графическое меню (rofi) + Разбор ошибок flake evaluation"
date: 2026-09-27
tags:
  - nixos
  - devlog
  - feature
  - fix
aliases:
  - "2026-09-27 automation layer rofi menu"
related:
  - "[[devlog]]"
  - "[[2026-09-27-automation-layer-impl]]"
---

# 2026-09-27 — Automation Layer: Графическое меню + Разбор ошибок flake evaluation

> [!info] Мета
> **Дата:** 2026-09-27 · **Тип:** `feature` / `fix` · **Статус:** ✅ решено

## Задача

Добавить графическое контекстное меню (rofi) для всех CLI-утилит автоматизации. Пользователь хотел, чтобы скрипты были доступны не только через CLI-алиасы, но и через графическое меню.

## Что сделано

### 1. Создан `scripts/automation-menu.sh`

Rofi-меню со списком всех утилит автоматизации (17 скриптов + 5 rofi-скриптов + wallpaper). При выборе элемента запускается соответствующая команда.

### 2. Добавлен в `scripts/default.nix`

```nix
automation-menu = pkgs.writeShellApplication {
  name = "automation-menu";
  text = readScript "automation-menu.sh";
  runtimeInputs = with pkgs; [ rofi ];
};
```

### 3. Обновлён `home/features/desktop/launcher/rofi.nix`

```nix
let
  scripts = import ../../../../scripts { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    scripts.rofi-image
    scripts.rofi-video
    scripts.rofi-audio
    scripts.automation-menu
  ];
}
```

### 4. Добавлен биндинг в `hyprland.nix`

```
bind = $mainMod, comma, exec, automation-menu
```

## Проблема: `flake check` не проходит

### Симптом

```
error: attempt to call something which is not a function but a set:
{ type = "derivation"; ... }
at /home/artlaus/nixos-config/scripts/default.nix:112:21:
  112|   automation-menu = pkgs.writeShellScriptBin "automation-menu" (readScript "automation-menu.sh") {
```

Ошибка указывала на `pkgs.writeShellScriptBin`, хотя на неё же ссылались ещё 22 рабочих записи в том же файле.

## Разбор — три независимых бага

### Баг 1 (главный): неверный API упаковки скриптов

`pkgs.writeShellScriptBin` принимает **ровно 2 аргумента** — `name` и `text`. Во всём `scripts/default.nix` использовался паттерн с тремя аргументами:

```nix
pkgs.writeShellScriptBin "extract" (readScript "extract") { runtimeInputs = ...; }
                                           └─ 1-й ─┘ └──── 2-й ────┘ └─ 3-й, лишний ─┘
```

Nix склеивает аргументы в список и применяет их по цепочке: `apply(apply(writeShellScriptBin, [name, text]), { runtimeInputs = ...; })`. Второй apply падает на готовом derivation → `attempt to call something which is not a function but a set: { type = "derivation"; ... }`.

`runtimeInputs` — это параметр **`writeShellApplication`**, а не `writeShellScriptBin`. Именно из-за этого атрибута и нужен правильный API.

**Исправление:** все 23 записи переведены на `writeShellApplication` (attrset-форма):

```nix
extract = pkgs.writeShellApplication {
  name = "extract";
  text = readScript "extract";
  runtimeInputs = with pkgs; [ unzip unrar p7zip gnutar zstd xz ];
};
```

Дополнительно `readScript` теперь срезает shebang (её генерирует сам `writeShellApplication`):

```nix
readScript = name:
  let text = builtins.readFile ./${name};
  in builtins.replaceStrings [ (builtins.head (builtins.split "\n" text)) ] [ "" ] text;
```

### Баг 2: attrset вместо списка в `home.packages`

`home.packages` — это **список** derivation'ов, а в двух модулях туда клался весь attribute set скриптов:

```nix
home.packages = with pkgs; [
  (import ../../../../scripts { inherit pkgs; })   # ← attrset, не список
];
```

- `home/features/desktop/launcher/rofi.nix` — заменено на явный список `rofi-image` / `rofi-video` / `rofi-audio` / `automation-menu`
- `home/features/cli/tools.nix` — заменено на `automationScripts ++ (with pkgs; [...])`, где `automationScripts = builtins.attrValues (import ../../../scripts { inherit pkgs; })`

Баг был латентным: при единственном элементе списка type-merge не запускался, и ошибка не всплывала. Она проявилась ровно после добавления второго элемента — из-за этого и указывало на `automation-menu`.

### Баг 3: несуществующие атрибуты пакетов

`runtimeInputs` стал вычисляться по-настоящему, и обнаружились невалидные имена пакетов. Проверка всех имён списков разом (вместо 15-минутных прогонов `flake check`):

```bash
nix eval --impure --expr '... builtins.filter (n: !(builtins.hasAttr n pkgs)) <имена>'
```

| Файл | Было | Стало | Причина |
|------|------|-------|----------|
| `scripts/default.nix` | `tar` | `gnutar` | `pkgs.tar` не существует |
| `scripts/default.nix` | `lzma` | убрано | переименован в `xz` (`renamed to/replaced by`) |
| `scripts/default.nix` | `hyprctl` | `hyprland` | `pkgs.hyprctl` не существует, `hyprctl` входит в пакет `hyprland` |
| `system/packages.nix` | `tar`, `lzma` | `gnutar`, убрано | то же |
| `system/virtualization.nix` | `smbclient`, `mountcifs` | `samba` | оба атрибута удалены из nixpkgs |
| `home/features/media/default.nix` | `qalculate` | `qalculate-gtk` | остались только `qalculate-gtk`, `qalculate-qt`, `libqalculate` |

Баги 3-го и 6-го пунктов — **предсуществующие**, не связанные с automation layer: они просто не достигались, пока `runtimeInputs`/`home.packages` падали раньше по цепочке.

### Баг 4: untracked-файл не попадает в источник флейка

`scripts/automation-menu.sh` не был добавлен в git. Для флейка на git-источнике Nix копирует в store только отслеживаемые git файлы, поэтому `builtins.readFile ./automation-menu.sh` упал бы с `path does not exist` при первой же сборке (на этапе `flake check` без сборки это не проявляется).

Фикс: `git add scripts/automation-menu.sh`.

## Методика

1. `nix flake check --no-build --show-trace` — воспроизведение с полным трейсом
2. По трейсу найдено, что падает **merge элемента списка** в `lib/types.nix:709-720` (`listOf` → `mergeDefinitions`), т.е. проблема в типе элемента, а не в самом `writeShellScriptBin`
3. Изолированная проверка атрибутов:
   ```bash
   nix eval --impure --expr 'let f = builtins.getFlake (toString ./.);
     pkgs = import f.inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
     in builtins.typeOf pkgs.writeShellScriptBin'
   # → "lambda"  (то есть проблема не в «несуществующей функции»)
   ```
4. **Главное ускорение** — вместо 15-минутных прогонов `flake check` проверять точечно (~40 секунд):
   ```bash
   # все скрипты сразу
   nix eval --impure --json --expr '... builtins.mapAttrs (n: v: v.drvPath) (import ./scripts { inherit pkgs; })'
   # все имена пакетов из nix-списков разом
   nix eval --impure --json --expr '... builtins.filter (n: !(builtins.hasAttr n pkgs)) <имена>'
   ```
   Имена извлекаются регексом из всех `= with pkgs; [ ... ];` в `home/`, `system/`, `hosts/`
5. `nix flake check --no-build` — финальная проверка, **EXIT=0**

> [!tip] Урок
> Ошибка «attempt to call something which is not a function but a set» с указыванием на **корректную** строку почти всегда означает, что проблема в **лишнем аргументе** (apply по цепочке), а не в отсутствии функции. Особенно когда один и тот же вызов работает в других местах — значит отличается не сама функция, а число аргументов или тип элемента.

> [!warning] Ошибки каскадируют
> Один сломанный атрибут (например `tar` в `runtimeInputs`) маскирует все, что стоит за ним в цепочке `lazy evaluation`. «Починил одну ошибку — получил три новых» здесь означает, что просто дошёл до следующего слоя. Проверять пакеты надо **пакетно** (все имена за один `nix eval`), а не по одному.

## Статус

- ✅ `automation-menu.sh` создан
- ✅ `scripts/default.nix` — все 23 скрипта на `writeShellApplication`
- ✅ `rofi.nix` / `tools.nix` — исправлен `home.packages`
- ✅ `hyprland.nix` — биндинг `SUPER + comma`, поправлены отступы
- ✅ `system/packages.nix`, `system/virtualization.nix`, `home/features/media/default.nix` — несуществующие пакеты
- ✅ `nix flake check --no-build` → **EXIT=0**

## Файлы, изменённые

- `scripts/automation-menu.sh` — новое
- `scripts/default.nix` — `writeShellApplication` + обрезка shebang + `gnutar`/`xz`/`hyprland`
- `home/features/desktop/launcher/rofi.nix` — явный список скриптов
- `home/features/cli/tools.nix` — `builtins.attrValues` + конкатенация
- `home/features/desktop/compositor/hyprland.nix` — биндинг `SUPER + comma`, отступы
- `home/features/media/default.nix` — `qalculate` → `qalculate-gtk`
- `system/packages.nix` — `tar` → `gnutar`, убран `lzma`
- `system/virtualization.nix` — `smbclient`/`mountcifs` → `samba`
- `docs/devlog.md`, `docs/devlog/2026-09-27-automation-layer-rofi-menu.md`
