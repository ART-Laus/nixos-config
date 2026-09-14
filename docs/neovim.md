# Neovim: исследование plugin management (актуально на 2026)

*Дата: 15.09.2026 · Обновлено: 15.09.2026 · Neovim stable 0.12, nixpkgs 25.05, Home Manager 25.05*
*Статус: ✅ утверждено — **Lazy.nvim** (гибрид) · Альтернатива `vim.pack` — ветка для эксперимента*

---

## 1. Текущее состояние вашего Neovim

- **Установка:** `programs.neovim.enable` + `vimPlugins.lazy-nvim` (один Nix-пакет).
- **Управление:** Lazy.nvim — все остальные ~30 плагинов качаются из GitHub **в рантайме** (`~/.local/share/nvim`), включая `markdown-preview` (бинарники), `treesitter` парсеры, `supermaven`.
- **Проблемы (из `about.md`):**
  - `colorscheme artgreendream` не существует → E185.
  - `vim.lsp.config()` / `vim.lsp.enable()` — API 0.11+, у вас 0.9.5.
  - `undofile` вкл→выкл, `snippets` путь не существует, форматтеры не установлены.
  - Не воспроизводимо, зависит от сети, не откатывается.

Вы **не** используете LazyVim (дистрибутив) — у вас собственный Lua поверх Lazy.nvim.

---

## 2. Сравнение вариантов (2026)

### A. Lazy.nvim (ваш текущий)

| Критерий | Оценка |
|---|---|
| Зрелость | ★★★★★ (101k stars, активно) |
| Lazy-loading | Отлично (events, keys, ft) |
| Декларативность | ★★☆☆☆ (lockfile есть, но версии в git, не в Nix) |
| Воспроизводимость | ★★☆☆☆ (сеть при первом запуске) |
| Удобство разработки | ★★★★★ ( `:Lazy update` мгновенно) |
| Nix-интеграция | Плохо без костылей (`reset_packpath = false`) |

**Когда выбирать:** если вы цените скорость экспериментов выше воспроизводимости и готовы хранить `lazy-lock.json` в git.

### B. Встроенный `vim.pack` (Neovim 0.11+ / 0.12 stable)

Появился в 0.11 (март 2025), стабилизирован в 0.12 (февраль 2026). Документация: `:help vim.pack`.

```lua
-- init.lua
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/folke/tokyonight.nvim",
})
-- Управление: :packupdate, :packdel, lockfile: ~/.config/nvim/nvim-pack-lock.json
```

| Критерий | Оценка |
|---|---|
| Зрелость | ★★★☆☆ (experimental, но «stable enough for daily use» — docs) |
| Lazy-loading | ★★☆☆☆ (только `:packadd` + `opt` пакеты, нет events/keys как в Lazy) |
| Декларативность | ★★★☆☆ (список в init.lua + lockfile JSON) |
| Воспроизводимость | ★★☆☆☆ (также сеть, но без внешнего менеджера) |
| Зависимость от Nix | Никакой (чистый Neovim) |
| Будущее | Официальный путь Neovim |

**Вывод:** `vim.pack` — **будущее Neovim**, но в 2026 ещё **не заменяет Lazy** по фичам. Если хотите минимализм и готовность к будущему — можно, но потеряете lazy-loading DSL.

### C. Nix / nixvim

**`programs.neovim.plugins = with pkgs.vimPlugins; [ ... ]`** (+ `extraLuaConfig`):

| Критерий | Оценка |
|---|---|
| Воспроизводимость | ★★★★★ (всё в /nix/store, откат) |
| Версионирование | ★★★★★ (через nixpkgs pin) |
| Lazy-loading | ★☆☆☆☆ (нет, всё грузится; можно через `packadd!` вручную) |
| Удобство | ★★☆☆☆ (каждый новый плагин → rebuild) |
| Читаемость Lua | ★★☆☆☆ (Lua внутри Nix-строк `''...''`) |

**nixvim** (flake `nix-community/nixvim`):

```nix
# modules/nixvim.nix
programs.nixvim = {
  enable = true;
  colorschemes.tokyonight.enable = true;
  plugins.treesitter.enable = true;
  plugins.lsp.servers.pyright.enable = true;
};
```

- Плюс: декларативно, типизировано, 300+ плагинов как опции.
- Минус: **Lua превращается в Nix** — ваша цель «Lua остаётся Lua» нарушается. Для 30 плагинов — большой Nix-код.

### D. Home Manager `programs.neovim` (без nixvim)

То же что C, но без обёртки nixvim — просто список `vimPlugins` + `extraLuaConfig`. Самый прямолинейный Nix-путь.

### E. Гибрид (рекомендую для вас)

```
Nix (flake.nix + home/features/cli/neovim/neovim.nix)
 ├── neovim package (0.12)
 ├── LSP/formatters/linters/treesitter parsers (бинарники)
 ├── ripgrep, fd, fzf, git (для telescope)
 └── (опционально) pinned plugins через pkgs.vimPlugins

Lua (~/.config/nvim/ — plain files, via xdg.configFile)
 ├── init.lua
 ├── lua/core/      (options, keymaps, autocmds)
 ├── lua/plugins/   (спеки — либо для lazy, либо для vim.pack)
 ├── lua/lsp/       (lsp config, использует Nix-бинарники)
 └── lua/ui/        (lualine, theme — берёт colors из theme/colors.nix)
```

**Граница:**

| Через Nix | Через Lua |
|---|---|
| `neovim` версия | `keymaps`, `autocmds` |
| `pyright`, `rust-analyzer`, `stylua`, `prettierd`, `nixd` ... | `plugin` **конфигурация** (`require("telescope").setup{...}`) |
| `ripgrep`, `fd`, `fzf` | `options`, `ui` |
| `vimPlugins.*` **если** хотите pin | `colorscheme` (генерируется из `theme/colors.nix`) |
| `treesitter` grammars (через `nvim-treesitter.withAllGrammars`) | Логика, команды, автокоманды |

---

## 3. Рекомендация для вашей системы

Учитывая ваши приоритеты (**Понятность > Модульность > Воспроизводимость**, «Lua существует чтобы конфигурировать Neovim через Lua», «прозрачный `~/.config/nvim/`»):

### Вариант 1 — «Прозрачный гибрид с Lazy» (рекомендую сейчас)

- **Оставить Lazy.nvim**, но **зафиксировать версии через Nix**:
  ```nix
  # home/features/cli/neovim/neovim.nix
  programs.neovim.plugins = with pkgs.vimPlugins; [ lazy-nvim ];
  xdg.configFile."nvim" = {
    source = ./nvim;  # ваш plain Lua
    recursive = true;
  };
  # + lazy-lock.json коммитится в git
  ```
  Lua остаётся читаемым, Nix гарантирует что `nvim` + `lazy-nvim` + `ripgrep` есть. Плагины всё ещё из сети, но lockfile даёт детерминизм.

### Вариант 2 — «Чистый Nix» (максимум воспроизводимости)

- Все плагины через `pkgs.vimPlugins`, Lua только `require` + `setup`. Подходит если готовы к `nixos-rebuild` ради каждого нового плагина. **Не рекомендую** — нарушает вашу цель прозрачности.

### Вариант 3 — «Будущее: vim.pack» (эксперимент)

- Заменить Lazy на `vim.pack.add()` в `init.lua`, хранить `nvim-pack-lock.json` в git. Минимализм, нет внешнего менеджера, но **теряете lazy-loading DSL**. Можно попробовать на отдельной ветке когда 0.12 станет вашим `pkgs.neovim`.

### Что делать с LazyVim

- **Не нужен.** LazyVim — дистрибутив (набор пресетов поверх Lazy). У вас уже своя конфигурация. Переход на LazyVim добавит абстракцию и скроет половину логики в их модулях. Если хотите попробовать — через `nix4lazyvim` флейк, но для ваших целей — избыточно.

---

## 4. Theme System + Neovim

Не дублировать HEX в `theme.lua`:

```nix
# home/features/cli/neovim/neovim.nix
let colors = import ../../../theme/colors.nix;
in {
  xdg.configFile."nvim/lua/theme.lua".text = ''
    return {
      bg = "${colors.bg}",
      primary = "${colors.primary}",
      secondary = "${colors.secondary}",
    }
  '';
}
```

```lua
-- nvim/lua/ui/theme.lua
local theme = require("theme")
vim.api.nvim_set_hl(0, "Normal", { bg = theme.bg, fg = theme.fg })
```

Или проще: генерировать `colors.lua` из Nix, а остальной UI — чистый Lua.

---

## 5. Итоговая рекомендация (утверждено 2026-09-15)

| Вопрос | Ответ |
|---|---|
| Нужен ли Lazy.nvim в 2026? | **Да — утверждено**. `vim.pack` — будущее, но пока без `event/keys/dependencies` DSL. Lazy даёт `один файл = один плагин` → ваша цель discoverability. |
| Нужен ли nixvim? | **Нет** — превращает Lua в Nix. |
| Где граница Nix/Lua? | Nix — `neovim 0.12` + бинарники (LSP/formatters/ripgrep/fd) + `lazy-nvim`; Lua — `keymaps/autocmds/UI/plugin setup` |
| Как мигрировать? | `home/features/neovim/neovim.nix`: `xdg.configFile."nvim".source = ./nvim;` + `lazy-lock.json` в git + `theme.lua` из `theme/colors.nix` |

> [!success] Решение
> **Гибрид с Lazy.nvim** — основной путь. `vim.pack` — экспериментальная ветка `feature/vim-pack` когда 0.12 станет `pkgs.neovim` и DSL догонит.

## 6. Структура после утверждения (flat + features)

```text
home/features/neovim/
├── default.nix        # features.neovim.enable
├── neovim.nix         # programs.neovim + xdg.configFile
└── nvim/
    ├── init.lua
    ├── lazy-lock.json
    └── lua/
        ├── core/
        ├── plugins/   # telescope.lua, lsp.lua — с config вместе (Lazy DSL)
        └── ui/theme.lua  # генерируется из theme/colors.nix
```

*Реализация — Phase 5 (см. [[architecture]] и [[2026-09-15-neovim]]).*
