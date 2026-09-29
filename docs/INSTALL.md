# Установка конфигурации NixOS на новый компьютер

**Документ-памятка.** Не девлог: здесь нет истории изменений, нет «что сделано / результат / решения».
Здесь только последовательность действий: что нажать, что вписать, что проверить.
Формат рассчитан на то, чтобы открыть файл в заметках и пройти его сверху донизу за один заход.

**Что покрыто:** установка с нуля на пустой компьютер → разметка → базовая NixOS → клонирование
репозитория → правка конфига под новое железо → первая сборка → первый вход → восстановление личного
окружения.

**Источник истины:** репозиторий `~/nixos-config` (remote `git@github.com:ART-Laus/nixos-config.git`,
ветка `main`, коммит `99eb3f6`). Все пути и номера строк ниже — актуальны для этого коммита.
Если строки «поехали» — ищи по имени опции, а не по номеру.

---

## Содержание

- [0. Что вообще нужно знать про этот конфиг](#0-что-вообще-нужно-знать-про-этот-конфиг)
- [1. Требования к железу](#1-требования-к-железу)
- [2. Что сделать ДО установки](#2-что-сделать-до-установки)
- [3. Этап 1 — загрузочная флешка](#этап-1--загрузочная-флешка)
- [4. Этап 2 — загрузка с флешки и разведка](#этап-2--загрузка-с-флешки-и-разведка)
- [5. Этап 3 — разметка диска](#этап-3--разметка-диска)
- [6. Этап 4 — снятие hardware-конфига](#этап-4--снятие-hardware-конфига)
- [7. Этап 5 — минимальный bootstrap-конфиг и nixos-install](#этап-5--минимальный-bootstrap-конфиг-и-nixos-install)
- [8. Этап 6 — клонирование репозитория](#этап-6--клонирование-репозитория)
- [9. Этап 7 — правка конфига под новую машину](#этап-7--правка-конфига-под-новую-машину)
- [10. Этап 8 — первая сборка](#этап-8--первая-сборка)
- [11. Этап 9 — первый вход в систему](#этап-9--первый-вход-в-систему)
- [12. Этап 10 — восстановление личного окружения](#этап-10--восстановление-личного-окружения)
- [13. Этап 11 — Project Orpheus (опционально)](#этап-11--project-orpheus-опционально)
- [14. Рабочие команды на каждый день](#14-рабочие-команды-на-каждый-день)
- [15. Диагностика типовых ошибок](#15-диагностика-типовых-ошибок)
- [Приложение A. Горячие клавиши](#приложение-a-горячие-клавиши)
- [Приложение B. Утилиты автоматизации](#приложение-b-утилиты-автоматизации)
- [Приложение C. Карта репозитория](#приложение-c-карта-репозитория)
- [Приложение D. Известные мелочи и поломки](#приложение-d-известные-мелочи-и-поломки)

---

## 0. Что вообще нужно знать про этот конфиг

Это flake-конфигурация. Один вход — `flake.nix`. Из него собираются:

| Слой | Что это | Как применяется |
|---|---|---|
| `nixosConfigurations.<хост>` | NixOS-система: ядро, systemd, сеть, сервисы, пользователи | `nixos-rebuild` |
| `home-manager.users.artlaus` | Home Manager, встроенный как NixOS-модуль | тем же `nixos-rebuild` |
| `homeConfigurations.artlaus` | автономный Home Manager | `home-manager switch` (запасной путь) |
| `devShells.x86_64-linux.default` | шелл с `nix` и `git` | `nix develop` |

**Главное следствие:** `sudo nixos-rebuild switch` применяет и систему, и домашний каталог
разом. Отдельно Home Manager запускать не нужно.

Четыре вложенных «кирпичика»:

- `hosts/msi-laptop/` — единственный хост. Внутри только импорты и `hardware-configuration.nix`.
- `system/` — 6 модулей, отвечают за машину: `nix`, `boot-hardware`, `networking-security`,
  `services`, `virtualization`, `packages`. (Файл `system/gaming.nix` существует, но **не подключён** — см. [Приложение D](#приложение-d-известные-мелочи-и-поломки).)
- `home/` — Home Manager, отвечает за пользователя: оболочка, терминалы, Neovim, Hyprland,
  панель, лаунчер, приложения, dev-тулы, медиа, автоматизация.
- `theme/` — единственный источник цветов и шрифтов (палитра «Artlaus Neon»), прокидывается
  в оба слоя через `specialArgs.theme`.

### Что система ставит (сводно)

- **Графика:** Hyprland (Wayland) + Waybar + rofi + dunst + swaylock/swayidle + hyprpaper
- **Вход в систему:** greetd + tuigreet (не SDDM/GDM)
- **Терминалы:** alacritty (основной), kitty
- **Оболочка:** zsh + oh-my-zsh + starship + zoxide + fzf
- **Редактор:** Neovim с lazy.nvim (ставится Home Manager, плагины подтягиваются при первом запуске)
- **Браузер:** Firefox + перенесённый с Windows профиль (тема, все `.xpi`, скрипты Tampermonkey,
  закладки, история, поисковики) — `home/features/desktop/firefox/`
- **Аудио:** PipeWire + WirePlumber + PulseAudio-совместимость + JACK
- **Сеть:** NetworkManager + nm-applet
- **Файлы:** Thunar + Thunar-GVFS, yazi, catfish
- **Сервисы:** Docker (по флагу), Ollama (с ROCm), Tor, OpenVPN-клиент, Tailscale, Nix-LD, AppImage
- **Утилиты:** 17 скриптов автоматизации + 46 инструментов discovery-expansion
- **Кэши:** `cache.nixos.org`, `nix-community.cachix.org`, `hyprland.cachix.org`

### Две особенности, которые ломают почти всё, если о них не знать

> ⚠️ **1. `builtins.getEnv` в `system/services.nix:79`**
> Там читается переменная `TAILSCALE_AUTHKEY_FILE`. Из-за этого **любая** оценка конфига
> становится *impure*, и без флага `--impure` Nix ругается:
> `error: ... 'getEnv' called in pure mode`.
> Затронуто всё: `nixos-rebuild`, `nix flake check`, `nix build .#...`, `home-manager switch`.
> Алиасы `rbs` / `rbb` / `upg` в `home/features/cli/shell/zsh.nix:97-99` уже с `--impure`.
> Если ключ не нужен — просто **не экспортируй** переменную, тогда `authKeyFile = null`
> и всё считается штатно (но всё равно impure, потому что `getEnv` в коде есть).
> Если ключ нужен — положи файл **внутрь репозитория** (например `~/nixos-config/.secrets/tailscale.key`),
> иначе абсолютный путь снаружи репозитория попадёт в store-путь флейка и сломает воспроизводимость.

> ⚠️ **2. `system.stateVersion = "25.05"` и `nixpkgs.url = ".../nixos-25.05"`**
> Конфиг привязан к ветке **nixos-25.05**. Ставь ISO той же ветки, иначе первая сборка
> переедет с другой версии nixpkgs на 25.05. `stateVersion` **не меняем** никогда —
> это «версия, на которой система была поставлена впервые», а не «текущая версия».

---

## 1. Требования к железу

Проверь до того, как начнёшь. Если что-то не совпадает — правки конфига описаны в [этапе 7](#этап-7--правка-конфига-под-новую-машину).

| Параметр | Требование | Где зашито | Что будет, если не так |
|---|---|---|---|
| Архитектура | **x86_64** (AMD64) | `flake.nix:31`, строки 49–56, `hardware-configuration.nix` | На ARM конфиг не соберётся. Нужно править 3 места |
| Прошивка | **UEFI**, без Legacy/CSM | `system/boot-hardware.nix:5-6` | `systemd-boot` не встанет. Нужен GRUB |
| Видеокарта | **AMD** (RDNA/RDNA2) — «как есть» | `system/boot-hardware.nix:17` (`hardware.amdgpu`), `system/services.nix:41,45` (ROCm) | Intel: убрать `hardware.amdgpu` и `cpu.amd.updateMicrocode`; Ollama на CPU. NVIDIA: отдельная секция, её в конфиге нет |
| Корень | **ext4** (или btrbs — см. примечание) | задаётся в `hardware-configuration.nix` | — |
| ESP | **FAT32**, 512 МБ–1 ГБ | то же | — |
| Мониторы | любые, автоопределение | `hyprland.nix:20` (`monitor=,preferred,auto,1`) | настроек конкретной модели нет — одинаково на любом железе |
| Клавиатура | раскладка `us,ru`, переключение `Alt+Shift` | `hyprland.nix:75-76` | если раскладка не нужна — поправить две строки |

**Примечание про btrfs:** NixOS поддерживает btrfs из коробки, но в этом конфиге нет
`boot.kernelParams` под btrfs и нет `subvolumes`-разметки. Если хочешь btrfs — используй
одну субволюцию на корень и добавь `options = "subvol=/@"` в `fileSystems."/"`,
плюс `boot.loader.systemd-boot` это переживёт, а `nixos-install` примонтирует
`/mnt` без субволюции — тогда `nixos-rebuild` в первый раз упадёт. **Проще ext4.**

**Процессор:** `hardware.cpu.amd.updateMicrocode` (в `hardware-configuration.nix`, который
мы генерируем заново) — это опция AMD. На Intel её в сгенерированном файле не будет,
и это нормально. Ядро — `pkgs.linuxPackages_latest` (`system/boot-hardware.nix:10`),
то есть всегда свежее; на очень новом железе может потребоваться
`pkgs.linuxPackages_zenity`.

---

## 2. Что сделать ДО установки

### 2.1 Резервные копии — что точно нужно

Ничего из этого не хранится в репозитории, всё это нужно вытащить **до** стирания диска.

- [ ] **SSH-ключи** (`~/.ssh/`) — без них не склонировать репозиторий (см. [этап 6](#этап-6--клонирование-репозитория))
- [ ] **GPG-ключи** (`~/.gnupg/`) — конфиг включает `programs.gnupg.agent` с SSH-поддержкой
- [ ] **Профили браузера** — Firefox в конфиге ставится с нуля, профиль не в репозитории
- [ ] **Пароли** — менеджер паролей (`pass` в системе есть, но сам он пуст)
- [ ] **Wallpapers** — 122 картинки, **в git их нет** (`.gitignore:37-38`), нужно скопировать отдельно
- [ ] **Музыкальная библиотека Orpheus** — 600 ГБ, живёт на отдельном диске/SMB, в конфиге только точка монтирования
- [ ] **`~/Documents/ALN`** — заметки, на которые ссылается алиас `aln` (`zsh.nix:93`)

Куда сложить: внешний диск, второй раздел, флешка. **Проверь, что файлы реально читаются с носителя**,
прежде чем продолжать.

### 2.2 Стратегия для нового хоста

Конфиг поддерживает несколько хостов, но `nixosConfigurations` сейчас содержит один ключ.
Два варианта:

- **Вариант А (по умолчанию в этом гайде) — переименовать.** Старая машина больше не нужна →
  переименовываем `hosts/msi-laptop` в `hosts/<новое-имя>` и правим `flake.nix`.
  Конфиг остаётся чистым, в нём один хост.
- **Вариант Б — добавить второй хост.** Старая машина остаётся →
  создаём `hosts/<новое-имя>/` с собственным `hardware-configuration.nix`,
  добавляем блок в `nixosConfigurations` в `flake.nix:69-88`. Старый блок не трогаем.
  Всё остальное (`system/`, `home/`, `theme/`) — общее, дублировать не нужно.

Далее описан **вариант А**. Пример имени хоста во всех командах — `newbox`;
подставь своё (без пробелов, латиницей, без точки).

### 2.3 Скачать ISO (единственный шаг, где интернет необходим по определению)

Нужен **NixOS 25.05**, минимальный (`*-nixos-minimal-x86_64-linux.iso`).
Полный образ не нужен: он весит ~2.5 ГБ против ~1 ГБ, а на нём ничего, что нужно этому конфигу.

Где брать (официальные страницы, без выдуманных прямых ссылок):

- <https://channels.nixos.org/nixos-25.05/> — каталог релизов ветки 25.05
- <https://releases.nixos.org/> — если ветки 25.05 уже нет в каталоге, ищи там `nixos-25.05*`
- <https://nixos.org/download/> — общая страница, но там по умолчанию «latest» (не 25.05)

В том же каталоге лежит файл `SHA256SUMS` (или `<имя>.iso.sha256`) — сверь хеш после скачивания.
Если ветки 25.05 в каталоге уже нет — см. врезку ниже.

> 💡 **Что делать, если ISO 25.05 недоступен.** Вариант «А»: поставить свежий ISO, а в
> `flake.nix:5` заменить `nixos-25.05` на нужную ветку и выполнить
> `sudo nix flake update ~/nixos-config` (пересканирует и обновит `flake.lock`;
> `home-manager` в `flake.nix:9` тоже стоит перевести на соответствующую ветку),
> после чего выставить `system.stateVersion` (`system/nix.nix:33`) в номер новой
> ветки, и то же самое в `home/default.nix:28`. Вариант «Б» (рекомендуемый): оставить
> флейк на 25.05, а `stateVersion` не трогать вообще — оставить `25.05`. Система
> соберётся из 25.05-пакетов, и это ровно то, на чём конфиг написан и отлажен.
> Второй вариант безопаснее.

---

## 3. Этап 1 — загрузочная флешка

Нужна флешка **8 ГБ или больше**. Данные на ней будут стёрты.

### Из Linux или macOS

```bash
# 1. Найти устройство флешки — по размеру и отсутствию точек монтирования
lsblk -o NAME,SIZE,TYPE,MODEL,TRAN,MOUNTPOINTS

# 2. Размонтировать все её разделы (подставь своё устройство)
sudo umount /dev/sdb1 2>/dev/null
sudo umount /dev/sdb2 2>/dev/null

# 3. Записать образ (bs=4M + conv=fsync — чтобы не обрезалось)
sudo dd if=nixos-minimal-25.05.xxxxxxx-x86_64-linux.iso \
        of=/dev/sdb bs=4M status=progress oflag=direct conv=fsync
sync
```

> ⚠️ `of=` — это **сырое устройство** (`/dev/sdb`), не раздел (`/dev/sdb1`) и не файл.
> Ошибка в этой букве стирает не флешку, а диск.

### Из Windows

1. Скачать [Rufus](https://rufus.ie/)
2. Device — флешка · Boot selection — **ISO Image File** · выбрать скачанный ISO
3. Partition scheme — **GPT** · Target system — **UEFI (non-CSM)**
4. File system — **Large FAT32** (или FAT32, если Rufus требует), остальное по умолчанию
5. Start → «Download» (Rufus сам докачает нужные UEFI-модули)

### Проверка

```bash
# На Linux/macOS — сверь хеш
sha256sum nixos-minimal-25.05.xxxxxxx-x86_64-linux.iso
# сравни с содержимым SHA256SUMS из того же каталога
```

Готово. Дальше — только локальные операции, интернет нужен будет лишь для загрузки
пакетов из кэша и для клонирования репозитория.

---

## 4. Этап 2 — загрузка с флешки и разведка

### 4.1 Загрузиться в режиме UEFI

Включи компьютер, открой boot-меню: `F12` (MSI), `F11` (Dell/Lenovo), `F9` (HP),
`Esc` (ASUS), `F8`/`F2`. Выбери загрузку с USB **и обязательно UEFI-вариант** —
в меню обычно два пункта на один USB: `UEFI: <флешка>` и просто `<флешка>`. Нужен первый.

В меню загрузки отключи **Secure Boot**, если он включён (NixOS с systemd-boot
не загрузится с ним без `shim`).

### 4.2 Проверить, что мы действительно в UEFI

Live-образ открывает shell автоматически (если нет — `Alt+F2`, затем `bash`).

```bash
test -d /sys/firmware/efi && echo "UEFI: OK" || echo "Legacy BIOS — стоп, установка не получится"
```

Если `Legacy BIOS` — выходи и перезагружайся в UEFI-режиме. Дальнейшие шаги
для Legacy-режима в этом гайде не описаны: конфиг заточен под systemd-boot.

### 4.3 Собрать факты о железе

Запиши себе вывод этих команд — они понадобятся в [этапе 7](#этап-7--правка-конфига-под-новую-машину):

```bash
# 1. Диски — как называть разделы при разметке
lsblk -e7 -o NAME,SIZE,TYPE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS,MODEL

# 2. Видеокарта — от этого зависит правка GPU-секции
lspci | grep -iE 'vga|3d|display'

# 3. Температурные сенсоры — пути для Waybar
for f in /sys/class/hwmon/hwmon*/name; do echo "$f -> $(cat $f)"; done
ls /sys/class/thermal/ 2>/dev/null

# 4. UEFI-раздел — есть ли он, смонтирован ли
efibootmgr -v
lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTLABEL | grep -i efi

# 5. Сетевые интерфейсы — имена нужны для проверки NetworkManager
ip -br link

# 6. Процессор
lscpu | grep -E 'Model name|Architecture'

# 7. Версия ISO
nixos-version
```

> 💡 `nixos-version` в live-образе покажет что-то вроде `25.05.20250901....`.
> Это подтверждает, что ISO той ветки, что нужна. Если нет — см. врезку в [2.3](#23-скачать-iso-единственный-шаг-где-интернет-необходим-по-определению).

### 4.4 Сеть в live-образе

```bash
# В live-образе сетевой менеджер обычно не запущен. Включи:
sudo systemctl start NetworkManager
ping -c3 cache.nixos.org
```

Если сети нет — всё равно продолжай: `nixos-install` скачает пакеты позже,
а репозиторий можно положить на флешку заранее (см. [этап 6](#этап-6--клонирование-репозитория)).

---

## 5. Этап 3 — разметка диска

> ⚠️ **Все команды в этом этапе уничтожают данные на указанном диске.**
> Перепроверь `lsblk` трижды, прежде чем напечатать первую команду разметки.

### 5.1 Схема

Рекомендуемая (для одного диска):

```text
nvme0n1
├── nvme0n1p1   1 GiB    EFI System Partition   FAT32   метка "boot"    → монтируется в /boot
├── nvme0n1p2   swap     Linux swap             swap    метка "nixos-swap" (опционально)
└── nvme0n1p3   остаток ext4                    ext4    метка "nixos"  → монтируется в /
```

Почему ESP 1 ГБ: `systemd-boot` ставит в `/boot/EFI` и ядра, и все поколения
конфигураций (`configurationLimit = 10` в `system/boot-hardware.nix:7`).
На 512 МБ при десяти поколениях теоретически может не хватить места.

**Swap.** Можно не делать. NixOS из коробки не требует swap; при нехватке памяти
включается zram. Если делаешь swap — 4–8 ГБ, и обязательно добавь в
`hardware-configuration.nix` через `swapDevices`, иначе он не подмонтируется.

### 5.2 Разметка (GPT + BIOS boot не нужен)

```bash
# Допустим, диск — /dev/nvme0n1. Подставь своё.
# Размонтировать, если смонтирован
sudo umount -R /dev/nvme0n1 2>/dev/null

# Создать таблицу разделов GPT и три раздела
sudo parted /dev/nvme0n1 --script \
  mklabel gpt \
  mkpart ESP  fat32  1MiB   1025MiB \
  mkpart swap linux-swap 1025MiB  9GiB \
  mkpart linux  ext4  9GiB   100%

# Убедиться, что разметка такая, как ожидалось
sudo parted /dev/nvme0n1 print
```

> 💡 На HDD (`/dev/sda`) то же самое, только устройство — `/dev/sda`, а имена разделов
> `sda1/sda2/sda3`. Если `parted` капризничает — используй `sfdisk --delete` для очистки
> таблицы или `sudo sgdisk --zap-all /dev/nvme0n1` для полного сброса перед `mklabel gpt`.
> На дисках >2 ТБ обязателен `mklabel gpt` (не dos) — иначе лимит раздела в 2 ТБ.
> Если `parted` жалуется на «unrecognised partition table» — это нормально после
> любой очистки; просто повтори разметку.

### 5.3 Форматирование

```bash
# EFI System Partition
sudo mkfs.vfat -F 32 -n boot      /dev/nvme0n1p1

# swap (пропусти, если не делал)
sudo mkswap -L nixos-swap /dev/nvme0n1p2
sudo swapon /dev/nvme0n1p2

# корень
sudo mkfs.ext4 -L nixos -m 1 /dev/nvme0n1p3
```

`-m 1` резервирует 1% под root — спасает систему, когда кончится место.

### 5.4 Монтирование

```bash
sudo mount /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot

# Проверка: должно быть видно ESP и корень
findmnt /mnt /mnt/boot

# Создать сборочные каталоги
sudo mkdir -p /mnt/etc/nixos
```

**ESP обязательно смонтирован в `/mnt/boot`** — иначе `nixos-install` не сможет
поставить `systemd-boot`, и система не загрузится.

### 5.5 Если несколько дисков

- Второй диск под данные (не системный): разметь и смонтируй его позже, уже в
  загруженной системе, через `fileSystems` в `hardware-configuration.nix`.
- Отдельный EFI на втором диске: **не делай** двух ESP с одинаковой меткой —
  systemd-boot загрузится с первого, а переменные EFI-разделов будут конфликтовать.

---

## 6. Этап 4 — снятие hardware-конфига

В репозитории лежит **заглушка**, а не настоящий файл:

```text
hosts/msi-laptop/hardware-configuration.nix
  ⚠️ ЗАГЛУШКА — замените на реальный файл
  fileSystems."/" = /dev/disk/by-label/nixos   ← метки, которой не будет
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ]   ← отключает автоопределение
  подписи fileSystems."/boot" и swapDevices — закомментированы
```

Его надо заменить целиком. Генерируем его **по смонтированному целевому диску** —
команда сама прочтёт твои разделы из `/mnt`:

```bash
sudo nixos-generate-config --root /mnt
```

Что это делает:
- записывает `/mnt/etc/nixos/hardware-configuration.nix` — **правильный** файл
  с твоими `fileSystems`/`swapDevices` (по UUID), `nixpkgs.hostPlatform`,
  `boot.initrd.availableKernelModules`, `hardware.cpu.*`, `hardware.enableAllFirmware`;
- записывает `/mnt/etc/nixos/configuration.nix` — дефолтный «общий» конфиг
  (NetworkManager, locale и т.д.). Его мы всё равно перезапишем своим на [этапе 5](#этап-5--минимальный-bootstrap-конфиг-и-nixos-install).

Посмотреть результат:

```bash
cat /mnt/etc/nixos/hardware-configuration.nix
```

> ⚠️ **О чём это предупреждение.** Если запустить `nixos-generate-config`
> **без** `--root` (например, `--show-hardware-config`), он возьмёт секцию
> `fileSystems` из **текущего** окружения — а ты в live-образе, где корень —
> squashfs/tmpfs. Разделы получатся мусором. `--root /mnt` решает эту проблему:
> разделы читаются из того, что смонтировано в `/mnt` и `/mnt/boot`.

Этот же файл сгенерится автоматически и при `nixos-install` (в `configuration.nix`
на «nix»-стиле, но с hardware тоже). А в репозиторий мы его скопируем на
[этапе 9.4](#94-hardware-configurationnix-обязательно--заменить-целиком) — после
перезагрузки он будет лежать в установленной системе по пути
`/etc/nixos/hardware-configuration.nix` (а пока живём в live-образе — в `/mnt/etc/nixos/`).

---

## 7. Этап 5 — минимальный bootstrap-конфиг и nixos-install

### 7.1 Почему не через флейк

Наивный путь — `nixos-install --flake`. Он не сработает по двум причинам:

1. **Нужен `git`**, а `nixos-rebuild` с флейком требует его уже сейчас. `git` есть в новой
   системе, которой ещё нет. Круговая зависимость.
2. Конфиг в репозитории — привязан к конкретной машине (разделы, пользователь, GPU)
   и в таком виде не пройдёт оценку.

Поэтому: ставим **минимальную систему без флейка** руками, а уже на ней — клонируем
репозиторий и переезжаем на флейк.

### 7.2 Написать `/mnt/etc/nixos/configuration.nix`

Сначала сгенерируй хеш пароля (пригодится и здесь, и на [этапе 9.2](#92-пароль-пользователя-обязательно)):

```bash
# в live-образе пакет whois недоступен, но nix с flakes включён — возьмём оттуда
nix shell nixpkgs#whois -c mkpasswd -m sha-512
# введёшь пароль дважды → получишь строчку вида: $6$C0RbVxxxxxxxx...xxxx

# запасной вариант без сети (openssl есть в live-образе из коробки):
openssl passwd -6    # формат хеша тот же ($6$ = SHA-512)
```

Создай файл (в live-образе есть `nano`; или переключись на `hx`/`vim`):

```bash
nano /mnt/etc/nixos/configuration.nix
```

Содержимое — **адаптируй разметку из [этапа 3](#этап-3--разметка-диска)** и подставь
свой UUID. Возьми UUID из `lsblk -o NAME,UUID` или из `blkid`:

```nix
{ config, pkgs, lib, ... }:

{
  imports = [ ];

  # ── Загрузчик (совпадает с system/boot-hardware.nix) ──
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # ── Ядро: то же, что в основном конфиге ──
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Разделы: подставь свои UUID и метки ──
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ТВОЙ-UUID-РАЗДЕЛА-КО-РНЮ";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ТВОЙ-UUID-ESP";
    fsType = "vfat";
  };

  # swapDevices = [ { device = "/dev/disk/by-uuid/ТВОЙ-UUID-SWAP"; } ];

  # ── Пользователь: ИМЯ_ПОЛЬЗОВАТЕЛЯ будет тем же, что и в конфиге ──
  users.users.ИМЯ_ПОЛЬЗОВАТЕЛЯ = {
    isNormalUser = true;
    description = "NixOS";
    extraGroups = [ "wheel" "networkmanager" ];
    # Хеш из mkpasswd выше. Без него sudo не заработает (пустой пароль sudo
    # отклоняет), а без sudo не будет ни nixos-rebuild, ни установки по гайду.
    initialHashedPassword = "ВСТАВЬ_ХЕШ_ИЗ_MKPASSWD";
  };

  # ── Минимальный набор для следующих шагов ──
  environment.systemPackages = with pkgs; [
    git          # клонировать репозиторий и работать с флейком
    wget
    curl
    git-lfs      # глобальный filter.lfs настроен в home/features/cli/git.nix
  ];

  # ── Nix: flakes обязательны, флейк без этого не прочитать ──
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "ИМЯ_ПОЛЬЗОВАТЕЛЯ" ];

  # ── Сеть ──
  networking.hostName = "newbox";          # подставь то же имя, что в hosts/<хост>/default.nix
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # ── Прочее ──
  time.timeZone = "Europe/Moscow";
  services.openssh.enable = true;          # чтобы зайти по SSH, если экран сдохнет

  system.stateVersion = "25.05";          # НЕ БЫТЬ 25.11/26.05 здесь — см. раздел 0
}
```

Как узнать UUID:

```bash
sudo blkid                       # покажет UUID для всех разделов
lsblk -o NAME,SIZE,UUID,LABEL
```

Сохранить и выйти: `Ctrl+O`, `Enter`, `Ctrl+X`.

### 7.3 Установка

```bash
# Проверь, что разделы на месте и ESP смонтирован
findmnt /mnt /mnt/boot

# Ставим
sudo nixos-install
```

`nixos-install` спросит пароль root (если не задан `--no-root-password`) и
**автоматически поставит `systemd-boot`**, потому что ESP смонтирован в `/boot`,
а в конфиге включён `boot.loader.systemd-boot.enable`.

Что произойдёт по шагам:
1. Соберётся минимальная система (5–15 минут в зависимости от скорости сети).
2. Создастся `/mnt/etc/nixos/flake.nix`-совместимое окружение: `nix-channel` на 25.05.
3. Поставится `systemd-boot` в ESP.
4. Попросит задать пароль root.

Полезные флаги:

```bash
sudo nixos-install --no-root-password                    # без пароля root
sudo nixos-install --flake /mnt/etc/nixos#default       # вариант с флейком (не наш путь)
sudo nixos-install --root /other/mnt                    # если монтировал не в /mnt
```

### 7.4 Проверка и перезагрузка

```bash
ls /mnt/boot/EFI/BOOT/       # должен быть BOOTX64.EFI
cat /mnt/etc/fstab
sync
sudo reboot
```

Извлеки флешку **до** перезагрузки — иначе live-образ загрузится снова.

---

## 8. Этап 6 — клонирование репозитория

Первая загрузка будет в **минимальную конфигурацию без графики**. Это нормально и нужно:
сейчас мы ставим фундамент, а не рабочую систему.

### 8.1 Войти

```bash
su - ИМЯ_ПОЛЬЗОВАТЕЛЯ
# либо залогинируйся сразу: логин ИМЯ_ПОЛЬЗОВАТЕЛЯ, пароль — пустой (Enter)
```

### 8.2 SSH-ключи

Репозиторий лежит на `git@github.com:ART-Laus/nixos-config.git` — нужен приватный ключ.

**Вариант 1 — перенести ключи со старой машины** (правильный, если старый компьютер есть):

```bash
# На СТАРОЙ машине: положи ключи на флешку/раздел
cp -r ~/.ssh /media/ФЛЕШКА/backup-ssh

# На НОВОЙ машине (под root, пока живёт в /mnt):
sudo mkdir -p /home/ИМЯ_ПОЛЬЗОВАТЕЛЯ/.ssh
sudo cp -r /media/ФЛЕШКА/backup-ssh/* /home/ИМЯ_ПОЛЬЗОВАТЕЛЯ/.ssh/
sudo chown -R ИМЯ_ПОЛЬЗОВАТЕЛЯ:ИМЯ_ПОЛЬЗОВАТЕЛЯ /home/ИМЯ_ПОЛЬЗОВАТЕЛЯ/.ssh
sudo chmod 700 /home/ИМЯ_ПОЛЬЗОВАТЕЛЯ/.ssh
sudo chmod 600 /home/ИМЯ_ПОЛЬЗОВАТЕЛЯ/.ssh/id_*
```

**Вариант 2 — сгенерировать новый ключ** (нужен доступ к GitHub с другого устройства):

```bash
ssh-keygen -t ed25519 -C "artlaus@newbox" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub          # скопировать это на github.com → Settings → SSH keys
ssh -T git@github.com               # проверка: "Hi <user>! You've successfully authenticated"
```

**Вариант 3 — без сети вообще.** Положи репозиторий на флешку заранее (со старой машины):

```bash
# На СТАРОЙ машине
git clone git@github.com:ART-Laus/nixos-config.git /media/ФЛЕШКА/nixos-config
# (или скопируй готовую ~/nixos-config целиком)

# На НОВОЙ машине
cp -r /media/ФЛЕШКА/nixos-config ~/nixos-config
cd ~/nixos-config && git status
```

> ⚠️ Репозиторий **обязан** лежать в `~/nixos-config`. От этого пути зависят алиасы
> `rbs`/`rbb`/`upg`/`upd`/`pkgs` (`home/features/cli/shell/zsh.nix:65,97-102`)
> и скрипты `wallpaper` и `doctor`.

### 8.3 Проверка клона

```bash
cd ~/nixos-config
git log --oneline -1          # ожидается 99eb3f6 или новее
git remote -v                 # origin → git@github.com:ART-Laus/nixos-config.git
git status                    # должно быть чисто
```

### 8.4 Убрать артефакты старой машины (важно)

```bash
# 1. Вендоренный клон antidote (WSL-артефакт, ~не в git, но лежит в дереве)
rm -rf ~/nixos-config/\~

# 2. Битая символическая ссылка на проект Orpheus:
#    репозиторий закоммитил symlink в /mnt/c/.../Desktop/ART_mytrash/Project_Orpheus
rm -f ~/nixos-config/home/features/desktop/orpheus/project

# 3. Пустые каталоги Orpheus не пережили клон — создать заново
mkdir -p ~/nixos-config/home/features/desktop/orpheus/data/navidrome
mkdir -p ~/nixos-config/home/features/desktop/orpheus/tools/slskd
# каталог data/filebrowser не нужен: docker-compose.nix ждёт ФАЙЛ data/filebrowser.db

# 4. Каталог обоев (в .gitignore, в клоне его нет)
mkdir -p ~/nixos-config/home/features/desktop/wallpapers
#   → скопируй сюда картинки со старой машины (122 файла, 212 МБ)
#   → либо возьми из репозитория dharmx/walls (нужны коллекции
#     anime / abstract / apocalypse / dreamcore)

# 5. Проверить, что не осталось битых симлинков
find ~/nixos-config -xtype l
```

---

## 9. Этап 7 — правка конфига под новую машину

Самый важный этап. Ниже — **полный** список. Сделай всё до первой сборки:
иначе либо не загрузишься, либо половина вещей молча не заработает.

Сделай это **до** [этапа 8](#этап-8--первая-сборка), на минимальной системе.

### 9.0 Сначала — посмотри, что вообще нужно поменять

```bash
cd ~/nixos-config
rg -n "artlaus|msi-laptop" --glob '!docs/**' --glob '!about.md' --glob '!flake.lock'
```

### 9.1 Имя пользователя (обязательно, 6 мест)

Если имя пользователя остаётся `artlaus` — **ничего не трогай**, всё уже готово.
Если меняешь — правь **все шесть** синхронно, иначе будет ошибка оценки
`The option users.users.artlaus.extraGroups does not exist`.

| Файл:строка | Что там | Что заменить |
|---|---|---|
| `flake.nix:32` | `username = "artlaus";` | новое имя. **Это главная точка** — от неё зависят и `home-manager.users.*`, и `homeConfigurations.*` |
| `home/default.nix:26` | `username = "artlaus";` | новое имя |
| `home/default.nix:27` | `homeDirectory = "/home/artlaus";` | `/home/НОВОЕ_ИМЯ` |
| `system/networking-security.nix:20` | `users.users.artlaus = {` | `users.users.НОВОЕ_ИМЯ = {` |
| `system/networking-security.nix:22` | `description = "artlaus";` | новое имя (не критично) |
| `system/nix.nix:8` | `trusted-users = [ "root" "artlaus" ];` | новое имя. **Без этого `nix` не даст тебе ничего собирать** |

Отдельно, **не трогай** (это не имя пользователя, а пространство опций):

- `home/default.nix:19` — `options.artlaus.cli.enable = lib.mkEnableOption ...`
- `home/features/cli/shell/zsh.nix:5` — `cfg = config.artlaus.cli;`

Если решишь переименовать и их — меняй **оба** одновременно, иначе zsh потеряет
весь конфиг молча.

> 💡 **Насколько важен `trusted-users`.** Без пользователя в этом списке `nix`
> не сможет писать в `/nix/store`: команды `nixos-rebuild`, `nix build` и `home-manager`
> будут падать с `error: cannot build ... because you are not trusted`.
> Симптом узнаваем.

### 9.2 Пароль пользователя (обязательно)

В `system/networking-security.nix:25` строка закомментирована:

```nix
# initialHashedPassword = "..."; # сгенерировать: mkpasswd -m sha-512
```

Это опция «пароль при создании аккаунта». Если на [этапе 5](#этап-5--минимальный-bootstrap-конфиг-и-nixos-install)
ты вписал хеш в bootstrap-конфиг — **аккаунт уже создан с паролем**, и здесь
ничего делать не нужно: строка так и останется закомментированной.

Если по какой-то причине пароль ещё не задан (bootstrap остался без хеша):
сгенерируй его и смени вручную после установки:

```bash
# прямо в загруженной системе
nix run nixpkgs#whois -- mkpasswd -m sha-512   # получить хеш (не обязательно)
passwd                                         # проще: сменить пароль напрямую
```

> 💡 Напоминание: `initialHashedPassword` срабатывает только при **создании**
> аккаунта. Для уже существующего аккаунта (наш случай — аккаунт создал bootstrap)
> сменить пароль можно только через `passwd`; правка опции в конфиге при
> пересборке **ничего не изменит**.

### 9.3 Имя хоста (обязательно, 4 места)

```bash
cd ~/nixos-config
git mv hosts/msi-laptop hosts/newbox
```

| Файл:строка | Что там |
|---|---|
| `hosts/newbox/default.nix:19` | `networking.hostName = "msi-laptop";` → `"newbox"` |
| `flake.nix:70` | `"msi-laptop" = nixpkgs.lib.nixosSystem {` → `"newbox"` |
| `flake.nix:74` | `./hosts/msi-laptop/default.nix` → `./hosts/newbox/default.nix` |

Папку переименовать **обязательно** — иначе `flake.nix:74` упадёт.
`flake.nix:82` и `:91` используют переменную `username`, там менять нечего.

> 💡 **Вариант Б (второй хост).** Не переименовывай. Создай `hosts/newbox/` копией
> `hosts/msi-laptop/`, замени в копии только `networking.hostName`, и в `flake.nix`
> добавь рядом с существующим блоком (после строки 85, перед `}];`) такой же:
> ```nix
> "newbox" = nixpkgs.lib.nixosSystem {
>   inherit system;
>   specialArgs = specialArgs;
>   modules = [
>     ./hosts/newbox/default.nix
>     home-manager.nixosModules.home-manager
>     {
>       home-manager.useGlobalPkgs = true;
>       home-manager.useUserPackages = true;
>       home-manager.extraSpecialArgs = specialArgs;
>       home-manager.users.${username} = import ./home;
>     }
>   ];
> };
> ```
> У каждого хоста — свой `hardware-configuration.nix`, сгенерированный на его железе.

### 9.4 hardware-configuration.nix (обязательно — заменить целиком)

```bash
# Берём файл, сгенерированный на этапе «снятия» и переживший перезагрузку.
# В live-образе он лежал по /mnt/etc/nixos/hardware-configuration.nix,
# после загрузки системы он находится по /etc/nixos/hardware-configuration.nix.
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hosts/newbox/hardware-configuration.nix
```

Потом **вручную** проверь в нём секции `fileSystems` и `swapDevices` — они должны
быть теми же, что в bootstrap-конфиге ([этап 5](#этап-5--минимальный-bootstrap-конфиг-и-nixos-install)).
Проверь, что:

- [ ] `fileSystems."/"` указывает на **твой** корневой раздел по UUID, `fsType = "ext4"`
- [ ] `fileSystems."/boot"` существует и указывает на ESP, `fsType = "vfat"`
- [ ] `swapDevices` на месте, если делал swap
- [ ] `nixpkgs.hostPlatform` = `"x86_64-linux"`
- [ ] **нет** строки `imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];` — она отключает автоопределение железа
- [ ] если не AMD — **нет** строки `hardware.cpu.amd.updateMicrocode`

Быстрая проверка, что файл вообще живой:

```bash
cd ~/nixos-config
nix eval --impure .#nixosConfigurations.newbox.config.system.build.toplevel.drvPath
```

Если вернётся путь derivation — файл оценивается. Если ошибка — читай сообщение,
в нём будет имя проблемной опции.

### 9.5 Видеокарта и GPU

По умолчанию конфиг написан под **AMD**:

```nix
# system/boot-hardware.nix:13-18
hardware.graphics = { enable = true; enable32Bit = true; };
hardware.amdgpu.opencl.enable = true;
hardware.enableAllFirmware = true;

# system/services.nix:39-46
services.ollama = {
  acceleration = "rocm";
  rocmOverrideGfx = "10.3.0";
  ...
};
```

**Если видеокарта AMD — ничего не трогай**, только проверь `rocmOverrideGfx`.
Строка `10.3.0` — это gfx1030 (серия RX 6000/6700, RDNA2). Если у тебя RX 7000 (RDNA3) —
это `11.0.0`, и вообще правильнее позволить ROCm определить самому, то есть **удалить
строку `rocmOverrideGfx` целиком**. Проверить можно после первой загрузки:

```bash
journalctl -u ollama | grep -i gfx
rocm-smi          # если есть в PATH
```

**Если видеокарта Intel:**

```nix
# 1. Убрать из system/boot-hardware.nix строку
#      hardware.amdgpu.opencl.enable = true;
# 2. В system/services.nix заменить
services.ollama = {
  enable = lib.mkDefault true;
  acceleration = "none";     # было "rocm"
  host = "127.0.0.1";
  port = 11434;
  openFirewall = false;
};                              # и удалить строку rocmOverrideGfx
```

**Если видеокарта NVIDIA — самый объёмный случай.** В конфиге поддержки NVIDIA нет
вообще, её нужно добавить (например, в `hosts/newbox/default.nix`):

```nix
{ config, ... }:
{
  # ── NVIDIA (заменяет AMD-блок в system/boot-hardware.nix) ──
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;      # true — если важны силы гибернации/Runtime PM
    powerManagement.finegrained = false;
    open = false;                        # открытые драйверы открыты только для новых desktop
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland на проприетарном драйвере: нужен EGLStreams или dma-buf
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
```

И в `system/boot-hardware.nix` убрать `hardware.amdgpu.opencl.enable = true`.
**Без Nvidia-блока карта будет черный экран в Hyprland.**
Для гибрида (AMD iGPU + NVIDIA дискретная) — отдельная история с `nvidia.prime`,
тут не расписываем.

### 9.6 Tailscale: переменная окружения и `--impure`

```nix
# system/services.nix:75-80
services.tailscale = {
  enable = true;
  useRoutingFeatures = "both";
  openFirewall = false;
  authKeyFile = if builtins.getEnv "TAILSCALE_AUTHKEY_FILE" == "" then null
                else builtins.toPath (builtins.getEnv "TAILSCALE_AUTHKEY_FILE");
};
```

Решения (выбери одно):

- **Не использовать авто-логин по ключу** (проще). Ничего не экспортируй —
  `authKeyFile` будет `null`, юзер залогинится руками через `tailscale up` после установки.
- **Использовать ключ.** Положи ключ **внутрь репозитория**:
  ```bash
  mkdir -p ~/nixos-config/.secrets
  echo 'tskey-auth-xxxxx' > ~/nixos-config/.secrets/tailscale.key
  chmod 600 ~/nixos-config/.secrets/tailscale.key
  echo '/.secrets/' >> ~/nixos-config/.gitignore     # и не коммить это
  export TAILSCALE_AUTHKEY_FILE=/home/ИМЯ/nixos-config/.secrets/tailscale.key
  ```
  Путь вне репозитория использовать **не надо**: `builtins.toPath` на абсолютный путь
  снаружи репозитория попадёт в store-путь флейка и сломает `nix flake copy`/CI.

> ⚠️ **В любом случае помни про `--impure`.** Пока в коде есть `builtins.getEnv`,
> все команды оценки должны идти с `--impure`. Проверить:
> ```bash
> cd ~/nixos-config
> nix flake check --impure            # без флага — ошибка "called in pure mode"
> ```

### 9.7 Project Orpheus — решение: включить, починить или выключить

Это самый «грязный» кусок конфига: в нём **абсолютные пути `/home/artlaus/...`**,
незаполненные плейсхолдеры SMB и коллизия портов. Выбери явно одно из трёх.

#### Вариант 1 — выключить на время установки (рекомендую для первого прогона)

Пока не настроена SMB-шара, не трогай Orpheus вообще. Чтобы убрать его из сборки,
убери одну строку из `home/features/desktop/default.nix`:

```nix
# было:
  imports = [
    ./compositor/hyprland.nix
    ...
    ./orpheus/default.nix      # ← закомментируй или удали
  ];
```

Системная часть (Docker) останется — она включается флагом в
`hosts/newbox/default.nix:24` и Orpheus не сломает.

Вернёшь обратно на этапе 11.

#### Вариант 2 — включить и починить

Что нужно исправить (файл `home/features/desktop/orpheus/`):

```nix
# mounts/library.nix:31-33  — ExecStart/ExecStartPost/ExecStop
#   /home/artlaus/...        → /home/НОВОЕ_ИМЯ/...
#   //LAPTOP-HOST/E$/Library → //<реальный-хост-или-tailscale-IP>/<реальная-шара>
#   uid=1000,gid=1000        → твои реальные uid/gid  (проверь: id -u && id -g)

# mounts/library.nix:13-19  — home.file ".config/orpheus/smb-credentials"
#   username=YOUR_USERNAME / password=YOUR_PASSWORD / domain=WORKGROUP
#   ⚠️ Это home.file → Home Manager заменит файл на СИМЛИНК в /nix/store (read-only).
#      Править его руками в ~/.config/orpheus/smb-credentials бессмысленно —
#      он будет перезаписан при каждой активации. Редактируй ТЕКСТ в library.nix.

# default.nix:15  — cd /home/artlaus/nixos-config/... → свой путь
# docker-compose.nix:18,36 — -v /home/artlaus/...        → свой путь
#        и -v .../data/filebrowser.db  ← ФАЙЛА НЕТ, docker создаст вместо него
#                                     каталог и монтирование сломается
```

Про UID/GID:

```bash
id -u; id -g
```

#### Вариант 3 — оставить как есть, но не запускать

Модуль импортируется, `home.file` создаются, но юниты `systemd --user`
ты не стартуешь — ничего не работает и ничего не ломается. Компромисс.

### 9.8 Коллизия порта 8080

Порт `8080` в конфиге занят трижды:

| Кто | Файл |
|---|---|
| Tor hidden service | `system/services.nix:67` (`HiddenServicePort = "80 127.0.0.1:8080"`) |
| Контейнер FileBrowser | `home/features/desktop/orpheus/docker-compose.nix:36` (`-p 8080:80`) |
| Скрипт `share` по умолчанию | `scripts/share:4` (`PORT="${1:-8080}"`) |

Tor слушает только `127.0.0.1`, так что с контейнером на `0.0.0.0` они не столкнутся
на уровне сокета им не страшно. Если Orpheus не используешь — забудь.
Если используешь — FileBrowser вызывай `share 9000`.

### 9.9 Git-идентичность

```nix
# home/features/cli/git.nix:10-11
userName  = "ART-Laus";
userEmail = "yzen26431@gmail.com";
```

Свои значения. Это попадёт в каждый твой коммит, включая коммиты в этот репозиторий.

### 9.10 Last.fm в панели

```bash
# home/features/desktop/bar/scripts/now.sh:9-10
USER="YOUR_USERNAME"
API_KEY="YOUR_API_KEY"
```

Ключ берётся на <https://www.last.fm/api/account/create>.
Пока не заполнено — скрипт на строке 15 сам себя отключает и печатает подсказку
в панели. Файл попадает в `/nix/store` через `writeShellApplication`, поэтому
правится **только в репозитории**, а не в `~/.local/bin/now.sh`.

### 9.11 Температуры в панели (waybar)

```nix
# home/features/desktop/bar/waybar.nix:52-57
temperature = {
  "hwmon-path" = [
    "/sys/class/hwmon/hwmon2/temp1_input"      # ← индекс hwmon у каждой машины свой
    "/sys/class/thermal/thermal_zone0/temp"
  ];
};
```

Индекс `hwmon2` — это WSL-наследие. Узнай свой:

```bash
for f in /sys/class/hwmon/hwmon*/name; do echo "$f -> $(cat $f)"; done
ls /sys/class/thermal/thermal_zone*
```

Подставь найденные пути. Модуль `temperature` сейчас **не выведен** в
`modules-left`/`modules-right` (`waybar.nix:19-20`), так что это не срочно —
до тех пор, пока не добавишь `"temperature"` в список модулей.

### 9.12 Дисплейная строка в Waybar (если десктоп)

```nix
# home/features/desktop/bar/waybar.nix:20
"modules-right" = [ "tray" "clock" "battery" ];
```

На машине без батареи модуль `battery` просто ничего не покажет.
Для десктопа замени на `[ "tray" "clock" ]`.

### 9.13 QMK/Vial

```nix
# home/features/desktop/apps.nix:22-23
qmk
vial
```

Это прошивка кастомной механической клавиатуры. Если такой клавиатуры нет —
убери обе строки, они только занимают место и время сборки.

### 9.14 ⚠️ НЕ РАСКОММЕНТИРУЙ `features.gaming.enable`

В `hosts/newbox/default.nix:23` есть комментарий-подсказка:

```nix
  # Раскомментируйте чтобы выключить кубик:
  # features.gaming.enable = false;
```

**Если раскомментировать — сборка упадёт.** Опция `features.gaming.enable`
объявляется только в `system/gaming.nix:7`, а этот файл **не импортирован**
ни в `hosts/`, ни где-либо ещё. Опции не существует → ошибка оценки.

Варианты:

- Хочешь Steam → добавь `../../system/gaming.nix` в список `imports` в
  `hosts/newbox/default.nix` (тогда флаг заработает).
- Не хочешь Steam → оставь строку закомментированной, Steam просто не будет.

### 9.15 Финальная проверка перед сборкой

```bash
cd ~/nixos-config
git status                     # видно, что ты наменял
nix flake check --impure       # полная оценка: ошибки и предупреждения
```

`nix flake check` прогоняет оценку всех outputs. Если он зелёный — конфиг
жив синтаксически и семантически.

---

## 10. Этап 8 — первая сборка

### 10.1 Сколько это займёт

**Первая сборка — самая долгая.** Из ~1500 пакетов большинство приедет
из бинарного кэша (cache.nixos.org, nix-community.cachix.org), это минуты.
Но в `home/features/cli/tools.nix` есть **10 пакетов, которые собираются локально
из исходников** через `runCommand` — они не лежат ни в одном кэше:

| Пакет | Способ | Строка в `tools.nix` |
|---|---|---|
| `px2ansi-rs` | `cargo install` | ~110 |
| `vinz` | `cargo install` | ~114 |
| `tuitab` | `cargo install` | ~126 |
| `tooi` | `cargo install` | ~131 |
| `bitchat-tui` | `cargo install` | ~136 |
| `puls` | `cargo install` | ~143 |
| `nix-pretty` | `cargo install` | ~160 |
| `coretilus` | `cargo install` | ~175 |
| `phosphor` | `pnpm add` | ~192 |
| `milli` | `pnpm add` | ~199 |

Rust-крейты собираются по 1–3 минуты каждый. Итого **20–60 минут только на это**,
плюс скачивание 8 discovery-флейков (nixmate, nixard, verynix, anima, super-comma,
nixy, niux, nix-bonsai).

**Как ускорить первую сборку** (рекомендую): временно закомментируй блок
`── Discovery Expansion ──` от `runCommand "px2ansi-rs"` до конца `milli` в
`home/features/cli/tools.nix`. Собери систему, убедись, что всё взлетело,
и потом верни блок и пересобери — второй раз эти 10 пакетов уже будут в
локальном кэше (`~/.cache/nix`), если не чистить.

### 10.2 Собрать

```bash
cd ~/nixos-config

# Проверить без применения (сборка от имени пользователя, без root)
sudo nixos-rebuild dry-build --flake .#newbox --impure
# или то же самое, но явно через nix:
nix build --impure '.#nixosConfigurations.newbox.config.system.build.toplevel' --dry-run
```

`--dry-run` покажет, что скачается, ничего не строя. Полезно, чтобы понять объём.

Потом — настоящая сборка и переключение:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#newbox --impure
```

Или, после перезагрузки раз в день, без перезагрузки:

```bash
# Именно эти алиасы уже прописаны в zsh.nix:97-99
rbs    # = sudo nixos-rebuild switch --impure --flake ~/nixos-config
rbb    # = sudo nixos-rebuild boot   --impure --flake ~/nixos-config
upg    # = sudo nixos-rebuild switch --impure --upgrade --flake ~/nixos-config
```

> 💡 **Как работает `--flake ~/nixos-config` без `#newbox`.** `nixos-rebuild`
> по умолчанию берёт атрибут по имени текущего хоста машины
> (`nixosConfigurations."<hostname>"`). Поэтому достаточно, чтобы имя хоста в
> системе (`networking.hostName`) **совпадало** с именем блока в `flake.nix`.
> Это честно работает и в варианте А, и в варианте Б — два хоста не мешают,
> пока `rbs` запускается на `newbox`, у которого флейковое атрибут-имя `newbox`
> есть. Сложности начинаются только если захочешь со стороны собирать хост
> `<имя-другого-хоста>`, отличный от текущей машины — тогда используй
> `nixos-rebuild switch --flake ~/nixos-config#<имя> --impure`.

### 10.3 Что делает `switch`

1. Собирает `system.build.toplevel` — всю систему.
2. Копирует результат в `/nix/store`, профили в `/nix/var/nix/profiles/`.
3. Активирует **Home Manager** для твоего пользователя (он подключён как NixOS-модуль,
   поэтому отдельного вызова не нужно).
4. Перегенерирует initrd, обновляет конфигурацию `systemd-boot` (`boot.loader.systemd-boot`).
5. Перезапускает изменившиеся сервисы.

Home Manager на этом шаге **перезапишет** всё, что он считает своим:
`.zshrc`, `.config/nvim/`, `.config/rofi/`, `.config/gtk-3.0/`, `.config/alacritty/`,
`.config/hypr/`, `.gitconfig`, `.config/orpheus/*`. Текущие (неуправляемые) версии
на диске будут заменены или переименованы в бэкап. Поэтому и делается бэкап
до установки.

### 10.4 Если Home Manager упал на активации

Самая частая ошибка на первой установке — HM не может записать в домашний каталог
(файлы от прошлой установки, read-only, битые симлинки).

**Способ 1** — автономный Home Manager из флейка (он у тебя объявлен):

```bash
nix profile install nixpkgs#home-manager     # один раз
home-manager switch --flake ~/nixos-config#artlaus
```

**Способ 2** — убрать то, что мешает, и переключиться заново:

```bash
# посмотреть, что HM не смог сделать
journalctl -u home-manager-artlaus.service -b --no-pager | tail -50

# убрать проблемные файлы
rm -rf ~/.config/nvim ~/.config/hypr ~/.config/alacritty ~/.config/rofi
# (только если на них нет ручных правок, которые жалко)

sudo nixos-rebuild switch --flake ~/nixos-config#newbox --impure
```

**Способ 3** — разово переключиться без графики, чтобы попасть в систему
и чинить изнутри (если Hyprland не стартует, а терминала нет):

```nix
# Временно в hosts/newbox/default.nix
services.getty.autologin = true;   # автологин на tty1, БЕЗ greetd
services.greetd.enable = false;
```

Верни как было после того, как всё заработает.

### 10.5 Перезагрузка

```bash
sudo reboot
```

---

## 11. Этап 9 — первый вход в систему

### 11.1 Что должно произойти

1. `systemd-boot` → пункт «NixOS» (первый, по умолчанию) → ядро
2. systemd → PipeWire, NetworkManager, greetd
3. **greetd + tuigreet** — терминальный экран входа с часами (`--time`)
4. Вводишь имя и пароль → запускается **Hyprland**
5. В Hyprland стартуют: `waybar`, `nm-applet`, Hyprpaper, Dunst, swayidle
6. Открываешь alacritty — стартует zsh со starship

### 11.2 Если Hyprland не запустился

Симптом: после входа в tuigreet — чёрный экран, либо возврат к экрану входа.

```bash
# Ctrl+Alt+F3 → консоль (root), логин ИМЯ_ПОЛЬЗОВАТЕЛЯ / пароль
```

Причина обычно в том, что **greetd запускает сессию с минимальным `PATH`**
(`/usr/bin:/bin`), а Hyprland из Home Manager лежит в `~/.nix-profile/bin`
и туда не попадает. tuigreet получает команду `Hyprland` и не находит её.

Исправление — указать абсолютный путь в `system/services.nix:9`:

```nix
services.greetd.settings.default_session = {
  command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/Hyprland --remember --remember-session";
  user = "greeter";
};
```

Второй вариант (если первый не помог) — обернуть в shell, чтобы экспортировать
профиль Home Manager:

```nix
command = "export PATH=$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH; ${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember --remember-session";
```

Третий, для чистоты — вообще отключить greetd и использовать Hyprland
с `exec-once = dbus-update-activation-environment --systemd` (обычно не требуется).

### 11.3 Проверка после входа

Открой alacritty (`SUPER+Return` или из лаунчера) и прогони:

```bash
# Инфраструктура
nix --version
git --version
docker --version && docker ps          # должен быть пустым, но команда работает
tailscale status
ollama list                           # Ollama поднялся?
journalctl -b --no-pager | grep -i error | head -30

# Home Manager
ls ~/.config/nvim/lua/                 # конфиг Neovim на месте
nvim --version | head -3
cat ~/.config/alacritty/alacritty.toml >/dev/null && echo "alacritty config OK"

# Графика и звук
echo $XDG_SESSION_TYPE                # ожидается wayland
echo $XDG_CURRENT_DESKTOP             # ожидается Hyprland
pactl info | grep "Server Name"       # PipeWire
wpctl status | head -20

# Waybar
hyprctl clients                       # список окон

# Пакеты
which eza bat ripgrep fd btop zoxide fzf lazygit delta git-lfs
```

### 11.4 Первый запуск Neovim

```bash
nvim
```

`lazy.nvim` уже установлен Home Manager (`home/features/cli/neovim/default.nix:13`),
поэтому при первом запуске он **сам** подтянет плагины из `lua/plugins/*.nix`.
Это займёт минуту. Дальше:

- `Space` — leader (пробел)
- `Space Space` — `Telescope` (в `keymaps.nix`)
- `Space f f` — файлы, `Space f g` — grep, `Space f b` — буферы
- `Space q` — записать и закрыть

Проверить, что LSP работает: `Space l s` → символы (`rust-analyzer`, `pyright`,
`nixd`, `lua-language-server`, `gopls` и ещё 9 установлены в
`home/features/development/default.nix`).

### 11.5 Wallpapers

```bash
# Файлы уже должны лежать в (если скопировал на этапе 8)
ls ~/nixos-config/home/features/desktop/wallpapers | wc -l   # ожидается ~122

# Рандомная обоина
SUPER+W     # вызовет скрипт `wallpaper`
# или вручную
wallpaper
```

Если каталог пуст — Hyprland покажет одноцветный фон (`theme.colors.bg` = `#001a0d`),
потому что `hyprpaper.nix` в качестве обоев указывает цвет, а не файл.

---

## 12. Этап 10 — восстановление личного окружения

### 12.1 Пароль

```bash
passwd                # если на этапе 7.2 оставил initialPassword = ""
sudo reboot           # и проверить, что sudo спрашивает пароль
```

### 12.2 SSH и GPG

```bash
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* && chmod 644 ~/.ssh/id_*.pub
ssh -T git@github.com                          # проверка доступа к репозиторию
gpgconf --reload gpg-agent                      # GPG-агент поднят из services/networking-security.nix
gpg --list-secret-keys                          # ключи на месте?
```

> 💻 Из-за `programs.gnupg.agent.enableSSHSupport = true` GPG-агент умеет
> подписывать и SSH. Если `ssh-add` ругается на отсутствие сокета —
> `export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"` в `~/.zshenv`.

### 12.3 Docker

```bash
id -nG | tr ' ' '\n' | grep docker      # пользователь в группе docker?
docker run --rm hello-world             # тест
```

Если группы нет — вышел не из сессии. `newgrp docker` или перезайди.

### 12.4 Tailscale

```bash
sudo tailscale up --ssh --accept-dns=false
tailscale status
tailscale ip -4
```

Полезно знать: `useRoutingFeatures = "both"` в `system/services.nix:77` включает
и subnet-router, и exit-node. Если планируешь использовать машину как exit-node:

```bash
sudo tailscale up --advertise-exit-node
# на других машинах: sudo tailscale up --exit-node=<эта-машина>
```

### 12.5 Звук

```bash
pavucontrol          # в конфиге есть, открывается по клику на иконку звука
wpctl status
systemctl --user status pipewire wireplumber
```

### 12.6 Bluetooth

```bash
blueman-manager      # services.blueman.enable = true
bluetoothctl show
```

### 12.7 Блокировка и сон

- `SUPER+L` → swaylock
- Крышка ноутбука → suspend (`system/boot-hardware.nix:43-46`)

### 12.8 Остальное личное

По необходимости:

```bash
ln -s /media/ФЛЕШКА/backup-gnupg ~/.gnupg      # GPG
mkdir -p ~/Documents/ALN                          # алиас `aln` из zsh.nix:93
```

**Firefox уже настроен.** Профиль (тема, все расширения `.xpi`, скрипты
Tampermonkey, закладки, история, cookies, поисковики, панель) лежит снимком
в `home/features/desktop/firefox/profile/` и раскладывается туда `home.activation`
при первой же сборке (см. модуль `home/features/desktop/firefox/default.nix`).
Дальше Firefox пишет в `~/.mozilla/firefox/artlaus` сам, пересборки его не трогают.

- **Обновить снимок** из Windows: заново вычистить исходный профиль по политике
  `home/features/desktop/firefox/exclude.txt`, заменить содержимое `profile/`
  и удалить `~/.mozilla/firefox/artlaus` на машине (снимок пересоберётся).
- **Пароли:** `logins.json`/`key4.db` зашифрованы ключом Windows (DPAPI) и
  намеренно исключены из репозитория. Единственный способ их перенести —
  войти в Firefox Sync (`Настройки → Синхронизация`) тем же аккаунтом FxA.
- **Чего нет в снимке** (регенерируется само): кэши сайтов >10 МБ
  (IndexedDB), кэши/телеметрия Firefox, Widevine/плагины (бинарники Windows),
  локальные origin'ы `localhost`/WSL, ключи шифрования Sync.

Проверить, что профиль на месте:

### 12.9 Общая проверка

```bash
doctor
```

Скрипт `scripts/doctor` (алиас `dc`) проверяет: nix, home-manager, упавшие сервисы,
диск, память, GPU, звук, сеть, DNS, Wayland, битые симлинки, наличие
`ffmpeg`/`imagemagick`/`jq`/`fd`/`ripgrep`.

> ⚠️ Две известные поломки в нём, они не про новую машину:
> - `nix flake check` на строке 9 запускается **без `--impure`** и упадёт
> - `find /home/artlaus` на строке 49 ищет не в твоём `$HOME`, если имя пользователя другое

### 12.10 Сделай первый коммит в репозиторий

После того как конфиг заработал — зафиксируй правки, чтобы следующая установка
не начиналась с нуля:

```bash
cd ~/nixos-config
git add -A
git status                    # проверь, что НЕ попали .secrets/ и обои
git commit -m "feat: port config to newbox — username, hostname, hardware, GPU"
git push
```

> ℹ️ Каталог `home/features/desktop/firefox/profile/` (≈0,5 ГБ) — это перенесённый
> с Windows профиль браузера, он **должен** попасть в коммит (см. модуль
> `home/features/desktop/firefox`). Он большой намеренно.

---

## 13. Этап 11 — Project Orpheus (опционально)

Музыкальная система: Navidrome (веб-сервер музыки) + FileBrowser (веб-файловый менеджер)
в Docker, плюс библиотека, примонтированная по SMB с другого компьютера.

Выполняй, только если [в этапе 9.7](#97-project-orpheus--решение-включить-починить-или-выключить)
выбрал вариант 2.

### 13.1 Включить обратно

```nix
# home/features/desktop/default.nix
  imports = [
    ...
    ./orpheus/default.nix      # ← вернуть
  ];
```

### 13.2 Узнать свои uid/gid и поправить монтирование

```bash
id -u     # например 1000
id -g
```

В `home/features/desktop/orpheus/mounts/library.nix:32` заменить:
- `//LAPTOP-HOST/E$/Library` → реальный хост (Tailscale-имя или IP) и реальная шара
- `/home/artlaus/Music` → `/home/ТВОЁ_ИМЯ/Music`
- `credentials=/home/artlaus/.config/orpheus/smb-credentials` → свой путь
- `uid=1000,gid=1000` → свои значения

### 13.3 Креды SMB

Файл `home/features/desktop/orpheus/mounts/library.nix:13-19` объявляет
`home.file.".config/orpheus/smb-credentials"`. **Правь текст в Nix-файле, не в
`~/.config/orpheus/`** — Home Manager перезапишет всё, что ты напишешь руками,
симлинком в `/nix/store`.

```nix
home.file.".config/orpheus/smb-credentials".text = ''
  username=ТВОЙ_ПОЛЬЗОВАТЕЛЬ
  password=ТВОЙ_ПАРОЛЬ
  domain=РАБОЧАЯ_ГРУППА
'';
```

Пересобери, потом:

```bash
systemctl --user daemon-reload
cat ~/.config/orpheus/smb-credentials     # проверь, что реальные данные
```

> ⚠️ **Безопасность.** Пароль окажется в git. Если репозиторий приватный —
> терпимо; если нет — перенеси в sops (в `system/networking-security.nix:53-54`
> есть закомментированные строки `sops.defaultSopsFile` и `sops.age.keyFile`
> как напоминание, что это планировалось).

### 13.4 Подготовить каталоги данных

```bash
cd ~/nixos-config/home/features/desktop/orpheus
mkdir -p data/navidrome          # база Navidrome (rw)
touch data/filebrowser.db        # ФАЙЛ, не каталог — docker ждёт именно файл
mkdir -p tools/slskd
```

> ⚠️ `data/` и `tools/` в git не попадают (пустые каталоги git не хранит),
> поэтому на свежем клоне их нет. Создай руками — конфиг этого не делает.

### 13.5 Поднять

```bash
# 1. Монтирование библиотеки по SMB
systemctl --user start orpheus-library-mount
mount | grep cifs
ls ~/Music                                # ожидаются папки исполнителей

# 2. Navidrome
systemctl --user start orpheus-navidrome
docker ps | grep orpheus
# → http://localhost:4533
#    При ПЕРВОМ запуске Navidrome покажет мастер создания админа — придумай пароль.
#    Если хочешь перенести существующую базу (navidrome.db) — положи её
#    в data/navidrome/ ДО первого старта, иначе будет пустая база.

# 3. FileBrowser
systemctl --user start orpheus-filebrowser
docker logs orpheus-filebrowser | grep -i password
# → сгенерирует случайный пароль админа при ПЕРВОМ запуске, покажет в логе
# → http://localhost:8080
```

Остановить всё: `systemctl --user stop orpheus-navidrome orpheus-filebrowser orpheus-library-mount`.

### 13.6 Автозапуск

Юниты помечены `WantedBy = default.target`, но `systemd --user` без `loginctl enable-linger`
не поднимет их после перезагрузки (сессия не запускается без логина).
Чтобы сервисы стартовали всегда:

```bash
sudo loginctl enable-linger ИМЯ_ПОЛЬЗОВАТЕЛЯ
```

### 13.7 Python-клиент Orpheus

```bash
# setup-venv — хелпер, созданный home.file
cat ~/.config/orpheus/setup-venv
# в нём:
#   cd <путь>/home/features/desktop/orpheus/project
#   source .venv/bin/activate
#   pip install -e . && pip install spotipy pyyaml pycryptodome mutagen pytest
```

Сам проект Orpheus (Python, `pyproject.toml`, 26 модулей) лежит **вне репозитория**.
Скопируй его в `home/features/desktop/orpheus/project/` (симлинк на эту машину
уже удалён на [этапе 8.4](#84-убрать-артефакты-старой-машины-важно)).

В `.env` проекта нужны `SPOTIFY_CLIENT_ID` и `SPOTIFY_CLIENT_SECRET`.

---

## 14. Рабочие команды на каждый день

Все алиасы живут в `home/features/cli/shell/zsh.nix` и
`home/features/automation/default.nix`.

### Nix

| Алиас | Развёрнуто | Что делает |
|---|---|---|
| `rbs` | `sudo nixos-rebuild switch --impure --flake ~/nixos-config` | применить конфиг |
| `rbb` | `sudo nixos-rebuild boot --impure --flake ~/nixos-config` | применить + обновить загрузчик, **без** перезагрузки |
| `upg` | `sudo nixos-rebuild switch --impure --upgrade --flake ~/nixos-config` | обновить зависимости флейка и применить |
| `upd` | `sudo nix flake update --flake ~/nixos-config` | только обновить `flake.lock` |
| `grb` | `sudo nix-collect-garbage -d` | почистить старые поколения |
| `nc` | `nixcheck` | диагностика конфига |
| `dc` | `doctor` | диагностика системы |

> ⚠️ `--impure` в `rbs`/`rbb`/`upg` — обязателен (см. врезку в разделе 0).
> В `nc` и `dc` его **нет**, поэтому `nixcheck` и часть `doctor` будут
> спотыкаться об impure-оценку. Лечится правкой `scripts/doctor:9`.

### Home Manager отдельно

```bash
home-manager switch --flake ~/nixos-config#artlaus   # только домашний каталог
home-manager generations                                # история поколений
home-manager rollback <поколение>                      # откат
```

### Nix-мусорка

```bash
nix-collect-garbage -d                    # удалить всё старше 30 дней (настроено в system/nix.nix:21-25)
nix store optimise --dry-run              # что оптимизируется (nix.optimise.automatic = true)
nix store gc --print-dead                 # что можно удалить
nix path-info -Sh                         # сколько занимает store
```

### Диагностика

```bash
nixos-rebuild dry-build --flake .#newbox --impure   # проверить, что соберётся, ничего не применяя
nix flake check --impure                            # полная оценка всех outputs
nix eval .#nixosConfigurations.newbox.config.networking.hostName --impure
journalctl -u home-manager-artlaus.service -b       # что делал Home Manager
systemctl --failed                                  # упавшие сервисы
```

---

## 15. Диагностика типовых ошибок

| Симптом | Причина | Что делать |
|---|---|---|
| `error: ... 'getEnv' called in pure mode` | нет `--impure` | добавь `--impure` к любой nix-команде |
| `error: you are not trusted` | пользователя нет в `trusted-users` | `system/nix.nix:8` → добавь имя, пересобери |
| `error: The option 'users.users.artlaus.extraGroups' does not exist` | имя пользователя изменено не везде | см. [9.1](#91-имя-пользователя-обязательно-6-мест) |
| `error: The option 'features.gaming.enable' does not exist` | раскомментировал подсказку в хосте, а `system/gaming.nix` не импортирован | верни комментарий (или импортируй файл) — [9.14](#914-не-раскомментируй-featuresgamingenable) |
| `error: path '/nix/store/…' is not part of the repository` | абсолютный путь снаружи репозитория попал в флейк (обычно `TAILSCALE_AUTHKEY_FILE`) | положи ключ внутрь репозитория — [9.6](#96-tailscale-переменная-окружения-и---impure) |
| Чёрный экран после входа в Hyprland | greetd запускает сессию с минимальным `PATH`, Hyprland из HM не виден | абсолютный путь к Hyprland в `system/services.nix:9` — [11.2](#112-если-hyprland-не-запустился) |
| Нет `git`, не открывается флейк | `git` не в системной корзине | `nix profile install nixpkgs#git` |
| `nix` не может ничего собрать | нет интернета / битый `flake.lock` | `sudo nix flake update ~/nixos-config` |
| `Home Manager activation failed` | не может записать в `~/` | [10.4](#104-если-home-manager-упал-на-активации) |
| Нет звука | PipeWire не поднялся | `wpctl status`, `systemctl --user status wireplumber pipewire` |
| Скриншот (`Print`) не работает | **в конфиге нет `grim`, `slurp`, `swappy`** | см. [Приложение D](#приложение-d-известные-мелочи-и-поломки) |
| Буфер обмена (`SUPER+V`) не работает | **нет `cliphist`** | там же |
| Обои одноцветные | каталог обоев пуст (в git его нет) | [8.4](#84-убрать-артефакты-старой-машины-важно) |
| Температура в панели не показывается | путь `hwmon2` с чужой машины | [9.11](#911-температуры-в-панели-waybar) |
| «Music: not playing» в панели | не заполнены ключи Last.fm | [9.10](#910-lastfm-в-панели) |
| Медленная первая сборка | 10 локальных `cargo install` | [10.1](#101-сколько-это-займёт) |
| Порт 8080 занят | Tor + FileBrowser + скрипт `share` | [9.8](#98-коллизия-порта-8080) |
| `docker: permission denied` | пользователь не перезашёл после добавления в группу | `newgrp docker` или перезайди |

---

## Приложение A. Горячие клавиши

Leader — **Super** (Meta/Windows). Источник: `home/features/desktop/compositor/hyprland.nix:92-146`.

### Запуск

| Клавиши | Действие |
|---|---|
| `SUPER + Space` | rofi (лаунчер приложений) |
| `SUPER + Return` | alacritty |
| `SUPER + B` | Firefox |
| `SUPER + T` | AyuGram (Telegram) |
| `SUPER + E` | Thunar (файловый менеджер) |
| `SUPER + Y` | yazi (терминальный файловый менеджер) |
| `SUPER + H` | btop (системный монитор) |
| `SUPER + N` | Planify (задачи) |
| `SUPER + K` | qalculate (калькулятор) |
| `SUPER + P` | ksnip (скриншот с аннотацией) |
| `SUPER + W` | сменить обои случайной картинкой |

### Окна и рабочие пространства

| Клавиши | Действие |
|---|---|
| `SUPER + ←/→/↑/↓` | фокус окна |
| `SUPER + SHIFT + стрелки` | двигать окно |
| `SUPER + F` | окно плавающим |
| `SUPER + SHIFT + F` | полный экран |
| `SUPER + G` | режим изменения размера |
| `SUPER + Q` / `SUPER + C` | закрыть активное окно |
| `SUPER + M` | выход из Hyprland |
| `SUPER + 1…0` | рабочее пространство 1…10 |
| `SUPER + SHIFT + 1…0` | переместить окно в пространство |
| `SUPER + колесо` | следующее / предыдущее пространство |
| `SUPER + ЛКМ` | двигать окно мышью |
| `SUPER + ПКМ` | менять размер мышью |

### Системные

| Клавиши | Действие |
|---|---|
| `SUPER + L` | блокировка (swaylock) |
| `SUPER + V` | история буфера обмена ⚠️ не работает — нет `cliphist` |
| `SUPER + R` | скрипты (rofi-scripts) |
| `SUPER + ,` | меню автоматизации (17 утилит) |
| `Print` | скриншот области ⚠️ не работает — нет `grim`/`slurp`/`swappy` |
| `SHIFT + Print` | скриншот всего экрана ⚠️ то же |
| `Alt + Shift` | переключение раскладки `us ↔ ru` |

### Neovim

Leader — **пробел**. Точные раскладки в
`home/features/cli/neovim/lua/config/keymaps.nix` (уже сгенерирован в
`~/.config/nvim/lua/keymaps.lua`).

---

## Приложение B. Утилиты автоматизации

17 утилит + меню — итого 18 скриптов, упакованных в `writeShellApplication`
(`scripts/default.nix`), устанавливаются в `home/features/automation/default.nix`
и `home/features/cli/tools.nix`.
Все — через rofi-меню (`SUPER + ,`) или напрямую.

| Алиас | Команда | Что делает |
|---|---|---|
| `ex` | `extract` | распаковать архив (zip/rar/7z/tar/zst/xz) — определяет формат сам |
| `ar` | `archive` | упаковать в архив (интерактивный выбор формата) |
| `fi` | `fileinfo` | тип файла, размер, EXIF-данные |
| `sh` | `share [порт]` | временный HTTP-сервер для каталога (по умолчанию 8080) |
| `dc` | `doctor` | диагностика системы |
| `nc` | `nixcheck` | диагностика Nix-конфига |
| `qr` | `make-qr` | QR-код из текста/URL |
| `oc` | `clip-ocr` | распознать текст из буфера обмена (tesseract) |
| `td` | `tidy-downloads` | разложить ~/Downloads по расширениям |
| `ir` | `img-resize` | изменить размер изображений |
| `ic` | `img-compress` | сжать изображения (optipng/pngquant/jpegoptim/gifsicle) |
| `va` | `vid2audio` | извлечь аудио из видео (ffmpeg) |
| `vg` | `vid2gif` | видео → GIF (ffmpeg) |
| `pt` | `pdf2text` | текст из PDF (poppler) |
| `br` | `batch-rename` | массовое переименование (интерактивно) |
| `fd` | `find-duplicates` | найти дубликаты (fdupes) |
| `hf` | `hashfile` | хеши файла |

Плюс медиа-скрипты: `rofi-image`, `rofi-video`, `rofi-audio`
(`scripts/media/*.sh`) — поиск и обработка медиа через rofi.
Плюс `rofi-scripts` (`SUPER + R`) — общий запуск скриптов.

---

## Приложение C. Карта репозитория

```text
flake.nix                       единственная точка входа: inputs, specialArgs, outputs
flake.lock                      ← НЕ УДАЛЯТЬ. Пины все версии, включая 8 discovery-флейков
.envrc                          `use flake` — для direnv/nix-direnv
.gitignore                      игнорирует обои, .obsidian, старые artlaus/

hosts/msi-laptop/
  default.nix                   импорты system/*, hostname, флаги features
  hardware-configuration.nix    ← ЗАГЛУШКА, заменяется на сгенерированный

system/                         отвечает за МАШИНУ
  nix.nix                       flakes, gc, substituters, trusted-users, stateVersion
  boot-hardware.nix             systemd-boot, amdgpu, pipewire, bluetooth, power, lid
  networking-security.nix       NetworkManager, firewall, локаль, пользователь, gnupg, polkit
  services.nix                  greetd+tuigreet, portals, ollama, nix-ld, appimage, tor, openvpn, tailscale
  virtualization.nix            docker + cifs-utils + samba (за флагом features.virtualization)
  packages.nix                  системные пакеты: шрифты, core CLI, иконки, библиотеки
  gaming.nix                    ⚠️ НЕ ИМПОРТИРОВАН — см. Приложение D
  openvpn/client/example.conf   шаблон VPN-конфига

home/                           отвечает за ПОЛЬЗОВАТЕЛЯ
  default.nix                   подключает все features/*, задаёт username/homeDirectory/stateVersion
  gtk-qt.nix                    GTK3/4 + qt6ct + kvantum + Papirus + Bibata
  features/
    cli/                        zsh+starship, alacritty+kitty, git+lfs+delta, yazi, tmux, neovim,
                                neofetch, tools (46 discovery-инструментов)
    desktop/                    hyprland, hyprpaper, waybar, rofi, dunst, swaylock, swayidle,
                                browsers, firefox/, apps, orpheus
    development/                python+pyright+ruff, nixd, rust-analyzer, gopls, LSP для TS,
                                dbeaver, pgadmin, postman, drawio, obsidian-инструменты
    media/                      vlc, obs-studio, strawberry, easyeffects, evince, libreoffice,
                                calibre, krita, gimp, obsidian, planify, ksnip, qbittorrent
    gaming/                     заглушка (Steam должен прийти из system/gaming.nix)
    automation/                 17 утилит + алиасы

home/features/desktop/firefox/  Firefox с перенесённым Windows-профилем
  default.nix                   модуль HM: firefox + seedFirefoxProfile (раскладывает снимок)
  profiles.ini                  указывает на каталог `artlaus`
  exclude.txt                   политика вычищения при импорте из Windows (rsync --exclude-from)
  profile/                      САМ СНИМОК ПРОФИЛЯ (≈0,5 ГБ): тема, все .xpi, Tampermonkey,
                                закладки, история, cookies, поисковики, панель, prefs.js

theme/                          ЕДИНСТВЕННЫЙ источник темы (specialArgs.theme)
  colors.nix                    палитра Artlaus Neon (#001a0d / #66FF99 / #C4A0FF)
  fonts.nix                     JetBrainsMono Nerd Font 14
  default.nix                   реэкспорт + toRgba

scripts/                        18 утилит автоматизации, упаковываются через writeShellApplication
  default.nix                   сборка всех скриптов в пакеты
  media/                        rofi-{image,video,audio}.sh

lib/theme.nix                   чистые функции (резерв под utils)
docs/                           этот гайд, архитектура, девлог
```

---

## Приложение D. Известные мелочи и поломки

Заранее знать, чтобы не тратить время на поиск причины.

### Не установлено, но используется

| Что | Где используется | Последствие |
|---|---|---|
| `grim`, `slurp`, `swappy` | `hyprland.nix:113-114` (`Print` и `SHIFT+Print`) | скриншоты не работают. Лечится добавлением в `home/features/cli/tools.nix` |
| `cliphist` | `hyprland.nix:27` (`exec-once`) и `:107` (`SUPER+V`) | буфер обмена не работает; в логе Hyprland будет ошибка при старте |
| `swaylock` в `system` | `hyprland.nix:107` | в `home.packages` есть (через HM), так что работает |

### Не подключено

| Файл | Симптом |
|---|---|
| `system/gaming.nix` | Steam не устанавливается; опция `features.gaming.enable` не существует |

### Сломанные ссылки и пути

| Что | Где | Что делать |
|---|---|---|
| `nn` → `/home/artlaus/scripts/new_note.sh` | `zsh.nix:94` | файла нет нигде; реальный — `scripts/new-note.nix`, но он тоже не ставится. Алиас мёртвый |
| `pkgs` → `nvim ~/nixos-config/nixos/packages.nix` | `zsh.nix:102` | путь неверный, правильно `system/packages.nix` |
| `aln` → `cd ~/Documents/ALN` | `zsh.nix:93` | каталога может не быть |
| `NOTES_DIR=/mnt/c/Users/user/Documents/ALN` | `scripts/new-note.nix:15` | WSL-путь, на нативном Linux не работает |
| `cmp` snippets | `cmp.nix:25` → `~/.config/home-manager/src/nvim/snippets` | HM не создаёт этот каталог — сниппеты не подгрузятся |
| `now.sh` Last.fm | `bar/scripts/now.sh:9-10` | плейсхолдеры; правится в репозитории |
| `h` / `http` | `zsh.nix:85-86` → команда `http` | пакет `httpie`/`httpstat` не установлен — алиас мёртв |
| `fd` → `find-duplicates` | `automation/default.nix:45` | перекрывает одноимённую утилиту `fd` в интерактивном shell — с флагами `fd --type f` работать не будет |
| `~` (папка-клон antidote) | `~/nixos-config/~/` | артефакт WSL, удалить |

### Дизайнерские решения, которые выглядят как баги

- `hyprpaper.nix` задаёт обоями **цвет** (`theme.colors.bg`), а не файл.
  Файловые обои включаются только скриптом `wallpaper` по `SUPER+W`.
- `waybar.nix:51-57` — модуль `temperature` описан, но не выведен в
  `modules-left`/`modules-right`. Мёртвая конфигурация.
- `home/default.nix:29-33` переопределяет `EDITOR`/`TERMINAL`, которые
  `zsh.nix:27-39` уже задал. Значения совпадают, конфликта нет, но дублирование есть.
- `flake.nix:13-16` — input `hyprland` объявлен и прокинут в `specialArgs`,
  но ни один модуль его не использует. Hyprland берётся из nixpkgs.
- `flake.nix:59-66` — `pkgs2`/`spkgs` оставлены для совместимости со старыми
  модулями. Сейчас никто их не использует.
- `.gitignore:19-24` — шесть правил для каталога `artlaus/features/cli/`,
  которого в репозитории уже нет. Мёртвые правила.

### Что не сходится между документами

- `docs/devlog/2026-09-27-automation-layer-audit.md` пишет `smbclient`,
  в `system/virtualization.nix` стоит `samba`.
- `docs/devlog/2026-09-25-super-key-hotkeys.md` пишет обои в `~/Pictures/wallpapers/`,
  фактически `home/features/desktop/wallpapers/`.
- `docs/devlog/2026-09-25-orpheus-music.md` говорит, что создан симлинк
  `Music → /home/artlaus/Music`; такого симлинка в репозитории нет.

---

*Конец памятки. При следующей установке правь этот файл, а не девлог —
он одноразовый, гайд переиспользуемый.*
