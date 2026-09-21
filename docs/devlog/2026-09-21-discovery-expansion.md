# NixOS Discovery Expansion — Catalog of Findings

*Date: 2026-09-21. Phase: Research only — nothing installed yet.*

---

## Inventory Summary (Blacklist)

Before presenting findings, here is the complete software inventory that serves as the blacklist:

**Explicitly installed CLI tools:** eza, bat, ripgrep, fd, fzf, zoxide, btop, jq, yq, ncdu, dog, mtr, entr, tldr, chafa, zip, unzip, unrar, p7zip, bzip2, ffmpeg_7, imagemagick, vips, lazygit, gh, git-lfs, delta, pass, pwgen, lm_sensors, usbutils, miller, tree, killall, timer, neofetch

**Shell/Terminal:** zsh, oh-my-zsh, zsh-autosuggestions, zsh-completions, fast-syntax-highlighting, zsh-autopair, zsh-you-should-use, starship, alacritty, kitty, tmux, yazi

**Development:** python3Full, pyright, ruff, nixd, nixpkgs-fmt, lua-language-server, stylua, rust-analyzer, gopls, golangci-lint, typescript-language-server, tailwindcss-language-server, vscode-langservers-extracted, bash-language-server, shellcheck, shfmt, dbeaver-bin, pgadmin4, postman, insomnia, drawio, xournalpp, hugo

**Media:** vlc, imv, qview, feh, ffmpeg_7, obs-studio, pavucontrol, playerctl, strawberry, easyeffects, evince, libreoffice, calibre, hunspell, krita, gimp3, gcolor3, obsidian, planify, ksnip, screenkey, qbittorrent

**Desktop:** xfce.thunar, xfce.catfish, xfce.exo, file-roller, ffmpegthumbnailer, gnome-epub-thumbnailer, f3d, openscad, networkmanagerapplet, brightnessctl, qmk, vial, discord, ayugram-desktop, firefox

**GTK/Qt:** adw-gtk3, papirus-icon-theme, bibata-cursors, nerd-fonts.jetbrains-mono, qt5ct, qt6ct, kvantum

**System:** git, curl, wget, htop, tor, openvpn, tailscale, docker, docker-compose, pciutils, usbutils, lm_sensors, libva-utils, clinfo, alsa-utils, pamixer, papirus-icon-theme, breeze-icons, various libraries, fonts (noto, nerd-fonts, carlito, terminus, inconsolata, font-awesome, liberation, dejavu, cantarell, unifont)

**Services:** greetd, tuigreet, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk, thunar, polkit_gnome, ollama, nix-ld, appimage-run, tor, openvpn, tailscale

**Gaming:** steam

**Neovim plugins (lazy.nvim):** telescope, nvim-tree, bufferline, lualine, cmp, noice, treesitter, alpha, autopairs, comment, colorizer, formatting-linting, langmapper, lspsaga, markdown, telescope, treesitter, yazi.nvim, lazy-nvim

---

## 🎨 Visual / ASCII / Terminal Graphics

### 1. px2ansi-rs

**What it is:** High-fidelity terminal image renderer and asset manager. Converts images into terminal-native art using 10 rendering styles.

**What it does:**
- 10 rendering styles: `ansi`, `unicode`, `fade`, `ascii`, `braille`, `full-block`, `dense`, `chinese`, `kanji`, `sixel`
- Fuzzy search + interactive TUI browsing for sprite libraries
- Truecolor + transparency via Oklab color space
- 5 resize filters (nearest → lanczos3)
- ASCII density control, monochrome output, Floyd-Steinberg dithering
- Image rotation, fetch mode (system info + rotating images)
- PNG rasterization (ANSI → PNG)
- SIMD pixel processing via LLVM auto-vectorization

**Why it's interesting:** This is the most comprehensive terminal image renderer I found. It goes far beyond chafa's capabilities with its 10 distinct rendering styles, interactive TUI browser, and fuzzy search. The braille and kanji styles produce remarkably detailed output.

**What I already have:** chafa (installed) — does basic ANSI/Unicode/Sixel rendering. px2ansi-rs offers fundamentally more styles and an interactive TUI browser that chafa lacks.

**Difference from chafa:** chafa is a renderer; px2ansi-rs is a renderer + asset manager + TUI browser with 10 distinct algorithms vs chafa's handful.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install px2ansi-rs` or GitHub release. Rust-based.

**Open Source:** Yes (MIT/Apache-2.0)

**Maturity:** Active development, recent releases

**Recommendation:** HIGH — unique capability, not duplicating chafa

---

### 2. phosphor

**What it is:** Render images, PDFs, and markdown in your terminal. Supports Kitty graphics protocol with Unicode virtual placement, Sixel, iTerm2, and halfblock fallback — with full tmux passthrough.

**What it does:**
- Auto-detects best protocol for terminal (Kitty > iTerm2 > Sixel > Halfblock)
- Supports PNG, JPEG, WebP, GIF, AVIF, TIFF, SVG, BMP, HEIC, PDF, Markdown
- Works inside tmux via virtual Unicode placement + DCS passthrough
- TypeScript library + CLI
- Programmatic API for embedding

**Why it's interesting:** phosphor solves the tmux image rendering problem elegantly. It works inside tmux (which chafa doesn't handle well) and auto-detects the best protocol. The PDF and Markdown support is unique.

**What I already have:** chafa (installed), imv/qview (image viewers), but none work inside tmux with protocol auto-detection.

**Difference from chafa:** phosphor works inside tmux, supports PDF/Markdown, auto-detects protocols. chafa is standalone and doesn't handle tmux passthrough.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `npm install -g phosphor` or GitHub release.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** HIGH — solves tmux image rendering, unique protocol auto-detection

---

### 3. fidelitty

**What it is:** Library for high-resolution integrated terminal graphics. Renders images using a custom bitmask font with Private Use Area codepoints.

**What it does:**
- 2×4 or 3×5 pixel resolution per terminal cell
- Custom font generated at runtime (no conflicts with existing fonts)
- >120fps with lower resolution
- Works over SSH
- Doubles as image compression
- Zig library + C header

**Why it's interesting:** This is a fundamentally different approach to terminal image rendering — using custom fonts in the Private Use Area rather than ANSI escape sequences. This means it works on ANY terminal that supports Unicode, even without truecolor or graphics protocols.

**What I already have:** chafa (ANSI-based), phosphor (protocol-based). fidelitty uses a completely different mechanism.

**Difference:** fidelitty works on terminals without truecolor/graphics support via custom Unicode fonts. Others require specific terminal capabilities.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install fidelitty` or Zig build.

**Open Source:** Yes

**Maturity:** Research/experimental stage

**Recommendation:** MEDIUM — novel approach but experimental, niche use case

---

### 4. ratty

**What it is:** GPU-rendered terminal emulator with inline 3D graphics. Inspired by TempleOS. Built with Rust & Ratatui + Bevy.

**What it does:**
- Inline 3D objects in terminal space (`.obj`, `.glb`, `.stl`)
- GPU-backed text rendering via Bevy/Vello
- Ratty Graphics Protocol (RGP) for 3D placement
- Camera control: flat, orthographic, perspective, Mobius views
- Spinning rat cursor (customizable)
- Terminal applications built around RGP: Ratscad (CAD), ComChan (serial monitor with 3D telemetry)

**Why it's interesting:** This is the first terminal emulator that renders actual 3D graphics inline. It's not a terminal emulator replacement — it's a new category of terminal that supports 3D content. The Ratty Graphics Protocol could become a standard.

**What I already have:** Nothing comparable. This is a completely new category.

**Difference:** No existing tool renders 3D objects inline in a terminal. This is category-defining.

**Installed:** NO

**NixOS:** Available via `nix run github:orhun/ratty` (flake). NOT in nixpkgs stable. Requires GPU + Bevy/wgpu support.

**Open Source:** Yes (MIT)

**Maturity:** Pre-release/preview. Active development.

**Recommendation:** HIGH — completely novel category, "wow" factor is maximum

---

### 5. milli

**What it is:** Pixel-perfect animated ASCII art engine. Renders images and GIFs to terminal, or exports as Go/Lua/JSON for embedding in TUIs and Neovim dashboards.

**What it does:**
- Render images, GIFs, video frames to terminal
- `.milli` pre-baked format for instant playback
- Export to Go/Lua/JSON for embedding
- Text effects (fire, glitch, wave, matrix, dissolve, typewriter, pulse, rainbow)
- Procedural shaders (plasma, rain, doomfire, starfield, tunnel, waves)
- Neovim dashboard plugin integration
- Truecolor glyph matching

**Why it's interesting:** milli bridges the gap between terminal rendering and application embedding. The `.milli` format and export capabilities make it useful for creating animated splash screens, dashboards, and MOTD animations. The Neovim integration is particularly valuable.

**What I already have:** chafa (static image rendering). milli adds animation, procedural generation, and embedding capabilities.

**Difference:** milli does animation and procedural generation; chafa does static rendering. milli exports to embeddable formats.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `npm install -g @amansingh-afk/milli`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** HIGH — animation + embedding + Neovim integration

---

### 6. vinz

**What it is:** 3D raymarching, procedural graphics engine for the terminal. Mathematical fluid simulations and ASCII art using 24-bit ANSI colors.

**What it does:**
- 10 2D visual styles + 8 3D raymarching styles
- 20 color palettes
- True color (24-bit RGB)
- Interactive UI with real-time control
- Procedural randomizer (press R for new shader)
- Written in C, single buffer writes for high FPS
- 3D vector math and raymarching engine from scratch

**Why it's interesting:** Pure procedural terminal art with real-time 3D raymarching. This is the "terminal screensaver" category taken to its logical extreme. The interactive UI and real-time shader generation is unique.

**What I already have:** Nothing comparable. No procedural terminal art engine.

**Difference:** Pure procedural 3D raymarching in terminal. No other tool does this.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install vinz` or GitHub release.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — pure toy/visual effect, but impressive

---

### 7. anima (yzs)

**What it is:** Standalone terminal animations toolkit from Yazelix. Boids, friends and enemies, Mandelbrot, Matrix rain, Game of Life, asciiquarium.

**What it does:**
- 12+ animation styles (boids, matrix, mandelbrot, game of life, friends_and_enemies, primordial, random, static, logo, asciiquarium)
- `yzs` binary with interactive and timed playback
- Kitty PNG frame sequence rendering
- Works in any capable terminal
- Nix flake available

**Why it's interesting:** Pure Nix-flakeable terminal animation toolkit. The asciiquarium and boids simulations are classic terminal art. The Nix integration is clean.

**What I already have:** Nothing comparable. No terminal animation toolkit.

**Difference:** Dedicated terminal animation toolkit with multiple simulation types.

**Installed:** NO

**NixOS:** Available via `nix run github:Yazelix/anima#yzs`. NOT in nixpkgs stable.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — fun, visual, Nix-native

---

## 🖼 Image / Media CLI

### 8. timg

**What it is:** Terminal image and video viewer. Renders media using terminal graphics protocols or Unicode/block-character fallbacks.

**What it does:**
- Sixel, Kitty, iTerm2 graphics protocols for full-resolution display
- 24-bit color + Unicode block fallbacks
- Image, GIF, and video preview
- Grid display, threaded loading
- Supports PDF, SVG, WebP

**Why it's interesting:** timg is the most mature terminal image/video viewer. It's been around since 2016, actively maintained, and supports the widest range of protocols and formats.

**What I already have:** chafa (installed), imv/qview (GUI viewers). timg is specifically designed for terminal-first image viewing with protocol detection.

**Difference:** timg is a dedicated terminal image viewer with protocol auto-detection and video support. chafa is more of a renderer. timg handles video playback.

**Installed:** NO (chafa is installed but serves different purpose)

**NixOS:** IN nixpkgs (`pkgs.timg`). Verified.

**Open Source:** Yes (GPL-2.0)

**Maturity:** Very mature (v1.6.3, 2025)

**Recommendation:** HIGH — in nixpkgs, mature, complements chafa with video support

---

### 9. viu

**What it is:** Simple terminal image viewer written in Rust. Uses terminal graphics protocols when available, falls back to character-cell rendering.

**What it does:**
- iTerm and Kitty graphics protocol support
- Block rendering fallback
- Image, GIF, input stream preview
- Lightweight, fast
- `viuer` library for embedding

**Why it's interesting:** viu is the minimalist alternative to timg. Extremely lightweight, focused on one thing: showing images in terminal. The `viuer` library makes it embeddable in other tools.

**What I already have:** chafa (installed). viu is simpler and more focused.

**Difference:** viu is simpler and lighter than chafa, with cleaner protocol support. But chafa already installed.

**Installed:** NO

**NixOS:** IN nixpkgs (`pkgs.viu`). Verified.

**Open Source:** Yes

**Maturity:** Stable

**Recommendation:** LOW — chafa already covers this category. viu is nice but redundant.

---

### 10. notcurses (and bundled tools)

**What it is:** Blingful character graphics/TUI library. Not a ncurses replacement — targets Unicode, 24-bit color, multimedia, terminal bitmap graphics.

**What it does (bundled tools):**
- `ncls` — multimedia-aware directory listings
- `ncneofetch` — neofetch clone using notcurses
- `ncplayer` — renders visual media
- `nctetris` — tetris in terminal
- `notcurses-demo` — capability demos
- `notcurses-info` — terminal diagnostics
- `notcurses-input` — keypress decoder
- `tfman` — terminal file manager

**Why it's interesting:** notcurses is the underlying library powering many modern terminal tools. The bundled tools alone are worth the install. `ncls` (multimedia directory listing) and `ncplayer` are unique capabilities.

**What I already have:** chafa (image rendering), btop (system monitor). notcurses provides a different rendering engine and bundled tools.

**Difference:** notcurses is a library + bundled toolkit. `ncls` and `ncplayer` have no equivalents in current stack.

**Installed:** NO

**NixOS:** IN nixpkgs (`pkgs.notcurses`). Verified.

**Open Source:** Yes (Apache-2.0)

**Maturity:** Very mature (v3.0.17)

**Recommendation:** HIGH — in nixpkgs, library + bundled tools, `ncls` is unique

---

### 11. dither

**What it is:** Image in, terminal splash script out — truecolor Unicode quadrant-block art rendered by dependency-free bash.

**What it does:**
- Renders truecolor Unicode quadrant-block art
- Auto-sized to caller's terminal
- Stdlib bash at runtime (no dependencies beyond bash 4+ and stty)
- Generates `show.sh` scripts from images
- Deterministic pipeline

**Why it's interesting:** The dependency-free bash approach is unique. You can generate a self-contained `show.sh` from any image and distribute it. No Python, no Rust, no Cairo — just bash.

**What I already have:** chafa (installed), imagemagick (installed). dither's bash-only approach is different.

**Difference:** Pure bash, generates standalone scripts. No runtime dependencies.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `git clone` + `make`.

**Open Source:** Yes

**Maturity:** Early (v0.1.0, 2026-08)

**Recommendation:** MEDIUM — novel bash-only approach, but early stage

---

## 🖥 TUI

### 12. zy

**What it is:** A blazing-fast, secure shell. 530+ builtins. 102 prompt modules. 39 themes. Built-in fuzzy picker, file manager, jumper, structured pipelines. One binary, Pure C.

**What it does:**
- 533 builtin commands (enforced by tests)
- Built-in file manager (`explore`) with three-pane Miller columns
- Built-in directory jumper (`zi`) with frecency
- Built-in fuzzy picker (`fzf` builtin)
- 100+ prompt modules (languages, cloud, git, system)
- 39 themes with OSC sequence terminal palette switching
- 17 value types, 60+ filter/transform commands
- JSON, CSV, TSV, TOML, YAML, XML, HTML, Markdown, NUON support
- Image preview via sixel/kitty graphics (when chafa/poppler/ffmpeg present)
- ~205,000 lines of C, single `.deb`

**Why it's interesting:** zy is a complete shell replacement that integrates everything into a single binary. The built-in file manager, fuzzy picker, and prompt modules eliminate the need for separate tools. It's designed to work WITH existing tools (zoxide, fzf) but also replaces them.

**What I already have:** zsh + oh-my-zsh + starship + zoxide + fzf + alacritty + yazi. zy would replace ALL of these with a single binary.

**Difference:** zy is a complete shell ecosystem in one binary. But replacing the current stack is out of scope for this phase.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `.deb` or source build. Pure C.

**Open Source:** Yes

**Maturity:** Active development, ~205K LOC

**Recommendation:** MEDIUM — impressive but would replace entire shell stack. Not in scope for discovery expansion.

---

### 13. lazyide

**What it is:** A full IDE in your terminal (written in Rust). Designed for SSH sessions and remote development.

**What it does:**
- File tree, tabbed editing, split panes
- LSP integration with inline ghost text and diagnostics
- Syntax highlighting for Rust, Python, JS/TS, Go, and more
- Code folding, bracket pair colorization
- Git gutter + side-by-side diff
- Minimap, project search, themes, remappable keybinds
- 32 themes with live preview
- Command palette (`Ctrl+P`) and fuzzy quick open (`Ctrl+O`)
- Autosave + crash recovery
- Agent Client Protocol (ACP) integration

**Why it's interesting:** This is a terminal IDE that pairs with agentic coding tools. It's designed for SSH workflows where you'd otherwise use a full GUI IDE. The ACP integration means AI agents can drive it.

**What I already have:** Neovim with lazy.nvim + LSP. lazyide is a different approach — more IDE-like, less modal-editor-like.

**Difference:** lazyide is an IDE (not a modal editor), designed for SSH/remote work with AI agent integration. Neovim is a modal editor.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install --git https://github.com/TysonLabs/lazyide` or `nix run`.

**Open Source:** Yes (MIT)

**Maturity:** Active development

**Recommendation:** MEDIUM — interesting but Neovim already covers the editing use case

---

### 14. hunk

**What it is:** Review-first terminal diff viewer for agent-authored changesets. Built on OpenTUI and Pierre diffs.

**What it does:**
- Multi-file review stream with sidebar navigation
- Inline AI and agent annotations beside the code
- Split, stack, and responsive auto layouts
- Watch mode for auto-reloading file and Git-backed reviews
- Mouse, pager, and Git difftool support
- Jujutsu and Sapling support
- TypeScript extensions system
- `HunkDiffView` component for embedding in OpenTUI apps

**Why it's interesting:** hunk is designed specifically for reviewing AI-generated code changes. The inline AI annotations and multi-file review stream are unique. It's not just a diff viewer — it's a review workflow tool.

**What I already have:** delta (installed, provides syntax-highlighted diffs). lazygit (installed, provides Git TUI). hunk adds AI annotations and review-first workflow.

**Difference:** hunk adds AI/agent annotations and review-first UI. delta is a diff pager. lazygit is a Git TUI. hunk is a review tool.

**Installed:** NO

**NixOS:** Has a `flake.nix` but NOT in nixpkgs stable. Available via `nix run github:hunkdiff/hunk`.

**Open Source:** Yes

**Maturity:** Active development, v0.20+

**Recommendation:** MEDIUM — useful for AI code review, but delta + lazygit cover existing needs

---

### 15. tuitab

**What it is:** Keyboard-driven terminal explorer for tabular data — CSV, TSV, JSON, JSONL, YAML, TOML, Parquet, Arrow, Excel, SQLite, DuckDB.

**What it does:**
- Filtering, sorting, pivots, joins
- Computed columns and charts
- Keyboard-driven navigation
- Supports 12+ data formats

**Why it's interesting:** This is a terminal data explorer that handles structured data formats natively. The pivot/join/computed-column capabilities make it a terminal spreadsheet.

**What I already have:** jq, yq, miller (installed) — text-based data processing. tuitab is a visual TUI explorer.

**Difference:** tuitab provides visual TUI interaction with tabular data. jq/yq/miller are CLI filters. Different paradigm.

**Installed:** NO

**NixOS:** IN nixpkgs (PR #554785, added as `tuitab`). Verified.

**Open Source:** Yes

**Maturity:** Stable, in nixpkgs

**Recommendation:** HIGH — in nixpkgs, unique visual data exploration

---

### 16. swpui

**What it is:** TUI to search and replace with a focus on ergonomics, speed and case awareness.

**What it does:**
- Interactive search and replace across files
- Case-aware matching
- Ergonomic keyboard-driven interface
- Fast, focused tool

**Why it's interesting:** A dedicated search-and-replace TUI. Not a general-purpose tool — specifically optimized for the find-and-replace workflow.

**What I already have:** ripgrep (installed for searching), sed/awk for replacement. swpui combines both in an interactive TUI.

**Difference:** Interactive search-and-replace TUI vs CLI ripgrep + sed. Different workflow paradigm.

**Installed:** NO

**NixOS:** IN nixpkgs (PR #524889, `swpui`). Verified.

**Open Source:** Yes

**Maturity:** Stable, in nixpkgs

**Recommendation:** MEDIUM — useful but ripgrep + sed already cover this

---

### 17. taskwarrior-tui

**What it is:** Terminal user interface for taskwarrior.

**What it does:**
- Interactive task management
- Keyboard-driven
- Integrates with taskwarrior CLI

**Why it's interesting:** If taskwarrior is ever installed, this provides a TUI interface. But taskwarrior isn't in the current stack.

**What I already have:** planify (installed — a task manager). taskwarrior-tui requires taskwarrior.

**Difference:** Requires taskwarrior backend. planify is already the task manager.

**Installed:** NO (taskwarrior not installed)

**NixOS:** IN nixpkgs (`pkgs.taskwarrior-tui`). Verified.

**Open Source:** Yes (MIT)

**Maturity:** Stable

**Recommendation:** LOW — requires taskwarrior, planify already installed

---

### 18. tuxedo

**What it is:** Fast, keyboard-driven terminal UI for todo.txt.

**What it does:**
- Interactive todo.txt management
- Keyboard-driven
- Fast, minimal

**Why it's interesting:** todo.txt format support with a beautiful TUI. But planify is already the task tool.

**What I already have:** planify (installed). tuxedo requires todo.txt format.

**Difference:** Different task management format (todo.txt vs planify's format).

**Installed:** NO

**NixOS:** IN nixpkgs (`pkgs.tuxedo`). Verified.

**Open Source:** Yes

**Maturity:** Stable

**Recommendation:** LOW — planify already covers task management

---

### 19. tooi

**What it is:** Text-based user interface for Mastodon, Pleroma and friends.

**What it does:**
- Terminal-based Mastodon client
- Textual TUI
- Interactive social media browsing

**Why it's interesting:** A terminal Mastodon client. Niche but interesting for terminal-first workflows.

**What I already have:** discord, ayugram-desktop (installed as GUI apps). No terminal social media client.

**Difference:** Terminal-based social media client. Completely different category.

**Installed:** NO

**NixOS:** IN nixpkgs (PR #557307, `tooi`). Verified.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — niche but interesting, terminal-first social media

---

### 20. bitchat-tui

**What it is:** TUI client for BitChat — secure, anonymous, peer-to-peer chat over BLE.

**What it does:**
- End-to-end encrypted P2P chat
- Bluetooth Low Energy transport
- Terminal-based interface
- Off-grid communication

**Why it's interesting:** This is the most unusual tool I found. Terminal-based encrypted P2P chat over Bluetooth. Completely off-grid communication.

**What I already have:** Nothing comparable. No encrypted P2P chat tool.

**Difference:** Completely unique category — encrypted P2P chat over BLE in terminal.

**Installed:** NO

**NixOS:** IN nixpkgs (PR #429235, `bitchat-tui`). Verified.

**Open Source:** Yes

**Maturity:** Early stage, experimental

**Recommendation:** MEDIUM — extremely niche, experimental, but fascinating concept

---

## 📊 System Visualization

### 21. kite

**What it is:** Modern cross-platform TUI system resource monitor written in Rust. Inspired by btop++.

**What it does:**
- Real-time CPU monitoring (per-core, frequency, load averages) with sparkline graphs
- Memory & swap usage with historical graphs and bar gauges
- Disk I/O rates and filesystem usage
- Network interface traffic with auto-scaling graphs
- GPU monitoring (NVIDIA NVML)
- Docker container monitoring
- Kubernetes pod monitoring (optional)
- SSH remote monitoring (optional)
- Prometheus metrics exporter (optional)
- Configurable alert rules in TOML
- 11 built-in themes
- Vim-style navigation
- Process management with signals

**Why it's interesting:** kite is the most feature-rich modern system monitor I found. The alert rules system, Docker/K8s integration, and Prometheus exporter are unique. The TOML configuration is clean.

**What I already have:** btop (installed). btop is a solid monitor but lacks kite's alert system, Docker/K8s integration, and Prometheus exporter.

**Difference:** kite adds configurable alert rules, Docker/K8s monitoring, Prometheus exporter, and SSH remote monitoring. btop is a simpler monitor.

**Installed:** NO (btop is installed but serves a different feature set)

**NixOS:** Not in nixpkgs. Available via `cargo install kite` or GitHub release.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — btop already installed, kite adds features but may be overkill

---

### 22. neotop

**What it is:** Linux-first terminal system monitor with per-core CPU spectrum, NVIDIA/AMD/Intel GPU dashboards, KVM hypervisor insight, container/runtime process grouping.

**What it does:**
- Per-core CPU spectrum with SMT/NUMA grouping
- Multi-vendor GPU dashboards (NVIDIA, AMD, Intel)
- KVM hypervisor insight
- Universal process grouping (every row in a named aggregate)
- Catppuccin themes
- Single binary, no daemons, no config required
- macOS port with functional parity

**Why it's interesting:** neotop has the most sophisticated GPU monitoring and process grouping. The "every row lives in a named aggregate" approach is unique — no headerless "misc" tail. The KVM insight is valuable for the virtualization setup.

**What I already have:** btop (installed). btop has basic process monitoring but no GPU dashboards or KVM insight.

**Difference:** neotop adds GPU dashboards (multi-vendor), KVM hypervisor insight, and sophisticated process grouping. btop has basic CPU/RAM/disk/network.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install neotop` or GitHub release.

**Open Source:** Yes

**Maturity:** Active development, v0.28+

**Recommendation:** HIGH — GPU monitoring + KVM insight + process grouping are unique

---

### 23. narsil

**What it is:** Terminal-based system resource monitor written in Rust — fast, readable, and GPU-aware. Named after Aragorn's sword.

**What it does:**
- Overview, CPU, Memory, Network, Disks, Processes, GPU tabs
- Braille charts for CPU
- Per-char label inversion
- Disk usage bars
- Status bar with keybindings
- Localised UI (EN/DE/FR/ES)
- GPU monitoring: AMD + NVIDIA + Intel (Linux)
- `cargo install narsil` or AUR/AppImage/Windows

**Why it's interesting:** narsil combines braille charts with GPU monitoring and localisation. The braille-based CPU visualization is visually distinctive.

**What I already have:** btop (installed). narsil adds braille charts and GPU monitoring.

**Difference:** Braille charts + GPU monitoring + localisation. btop has standard bar charts.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install narsil`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — braille charts are visually interesting but btop covers core needs

---

### 24. dreidel

**What it is:** Fast, keyboard-driven Linux-first terminal system monitor with clear dashboard layout and focused drill-down views.

**What it does:**
- CPU — per-core line charts with scrollable history and per-core temperatures
- Network — per-interface RX/TX rates with full-screen graph drill-down
- Disk — per-device capacity info with read/write rate graphs
- Process — sortable, filterable with detail overlay and signal support
- Status bar — clock, uptime, load averages, RAM/swap gauges
- 4 layouts: sidebar, classic, dashboard, grid
- TOML configuration

**Why it's interesting:** dreidel's layout system and drill-down approach is unique. The network and disk drill-down views (full-screen graphs) are particularly well-designed.

**What I already have:** btop (installed). btop has similar features but dreidel's layout system and drill-down UX is different.

**Difference:** dreidel's layout presets and drill-down UX differ from btop's approach.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install dreidel`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — btop already covers system monitoring

---

### 25. vitals

**What it is:** Terminal resource monitor for Linux built with notcurses. Displays CPU, memory, network, storage, and thermal data in a responsive multi-panel TUI.

**What it does:**
- CPU, Memory, Network, Storage, Thermal panels
- 24-bit color using Catppuccin Mocha palette
- Adaptive layout (3-column wide, 2-column medium, stacked narrow)
- Built on notcurses (no pre-installed dependency needed)

**Why it's interesting:** Built on notcurses, which means it has access to advanced terminal graphics. The adaptive layout system is unique.

**What I already have:** btop (installed). vitals uses notcurses for rendering.

**Difference:** notcurses-based rendering with adaptive layout. btop uses different rendering.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via source build (CMake).

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — notcurses rendering is interesting but btop covers needs

---

### 26. tempest-monitor

**What it is:** Stunning, real-time terminal system monitor for macOS and Linux. Built with Rust.

**What it does:**
- Overview, CPU, Memory, Disks, Network, Processes, GPU, Services, Sockets tabs
- Historical persistence (7-day rolling window in SQLite)
- Prometheus-compatible exporter
- PNG/JSON machine-state snapshots
- Intelligent alerting with desktop notifications
- Full async engine (tokio)
- macOS: powermetrics for GPU/power metrics
- Linux: sysfs/hwmon for temperature/GPU
- NVIDIA NVML support

**Why it's interesting:** tempest-monitor has the most comprehensive feature set — historical persistence, Prometheus exporter, PNG snapshots, and macOS-specific powermetrics integration. The 7-day SQLite history is unique.

**What I already have:** btop (installed). tempest-monitor adds historical persistence and Prometheus export.

**Difference:** 7-day historical persistence, Prometheus exporter, PNG snapshots. btop has no history.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install tempest-monitor`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — historical persistence is unique but btop covers core needs

---

### 27. puls

**What it is:** Unified system monitoring and management tool for Linux. Combines resource monitoring with system administration.

**What it does:**
- CPU, Memory, Disk, Network, GPU monitoring
- Systemd service management (start/stop/restart/enable/disable)
- Journal log viewer
- GRUB configuration editor
- Container engine integration (Docker socket)
- Process tree with resource usage score
- Language detection (Turkish/English)
- Read-only and read/write modes

**Why it's interesting:** puls combines monitoring AND system administration in one TUI. You can monitor services AND manage them AND edit GRUB AND view journal logs — all in one tool.

**What I already have:** btop (monitoring), systemctl (service management), journalctl (logs). puls combines all three.

**Difference:** Unified monitoring + administration + GRUB editing + journal viewing in one TUI.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install puls` or GitHub release.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — unified admin+monitor is interesting but requires sudo for full functionality

---

### 28. voidmon

**What it is:** Sleek, hacker-aesthetic terminal system monitor written in Go.

**What it does:**
- CPU, Memory, Disk, I/O, Network, GPU, Power, Processes
- Cross-platform GPU support (NVIDIA, AMD, Intel, Apple Silicon)
- Power/battery monitoring
- Top 15 processes by CPU
- One-liner install

**Why it's interesting:** The hacker-aesthetic design and Go-based implementation make it lightweight and visually distinctive.

**What I already have:** btop (installed). voidmon is a simpler alternative.

**Difference:** Go-based, hacker aesthetic, simpler than btop.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `go install` or GitHub releases.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** LOW — btop already installed and more feature-rich

---

### 29. xtop

**What it is:** Modern, cross-platform TUI system monitor written in Rust. Inspired by btop.

**What it does:**
- CPU per-core with temperature sensing
- RAM and Swap monitoring with historical chart
- Network RX/TX tracking per interface
- Storage and Disk I/O visualization
- Process list with live search
- GPU and Battery monitoring (stub)
- 13 color themes with custom theme support via JSONC
- 7 built-in layouts with custom layout support via JSONC
- Full-screen mode for any widget
- Configurable alert thresholds

**Why it's interesting:** Similar to btop but with JSONC configuration and more layout options. The theme system via JSONC is interesting.

**What I already have:** btop (installed). xtop is a btop alternative.

**Difference:** JSONC configuration, more layouts. But btop already installed.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install xtop`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** LOW — btop already installed, xtop is an alternative

---

## 🧬 Nix / System Internals

### 30. nixmate

**What it is:** All your NixOS tools in one TUI — generations, rebuilds, services, errors, and more.

**What it does:**
- Generations: browse, diff, delete, pin, restore. Side-by-side package comparison
- Error Translator: paste a Nix error, get human explanation + fix. 50+ patterns. AI fallback (Claude/OpenAI/Ollama)
- Services & Ports: systemd + Docker + Podman in one view. Port mapping. Start/stop/restart. Live logs
- Storage: Disk dashboard. Store breakdown (live/dead paths). GC, optimize, full clean
- Config Showcase: Auto-generate system poster + config architecture diagram as SVG
- Options Explorer: search.nixos.org in terminal. Fuzzy search, tree browsing
- Rebuild: Live nixos-rebuild dashboard. 5-phase progress. Post-build diff
- Flake Inputs: Selective per-input updates
- Package Search: Fuzzy search across 100k+ packages
- Nix Doctor: Health score 0-100. Automated checks with one-click fixes
- Pipe mode: `nixos-rebuild switch 2>&1 | nixmate`

**Why it's interesting:** This is the ultimate NixOS management TUI. It replaces `nixos-rebuild`, `nix-collect-garbage`, `nix search`, `systemctl`, and more with one keyboard-driven tool. The AI error translator and Nix Doctor are unique.

**What I already have:** nix (installed), nix flake commands, systemctl. nixmate provides a unified TUI interface for all of these.

**Difference:** Unified TUI for all NixOS operations + AI error translation + health score. No equivalent in current stack.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix run github:manelinux/nixmate` or `nix profile install github:manelinux/nixmate`.

**Open Source:** Yes

**Maturity:** Active development, 10 modules, 13 themes, EN/DE

**Recommendation:** HIGH — comprehensive NixOS management, AI error translator, Nix Doctor

---

### 31. nixard

**What it is:** Interactive terminal UI for exploring NixOS package closures, analyzing real installation costs, and generating ready-to-use Nix declarations.

**What it does:**
- Package exploration with local SQLite database
- Real closure analysis (dependency inspection)
- Local store auditing
- Configuration inspection (detects configuration.nix, flakes, Home Manager)
- Export/history management
- Integrated `.nix` editor
- Mark packages and export as `.nixard` files
- Persistent export history
- `.narinfo` caching for fast repeated lookups

**Why it's interesting:** nixard provides real closure analysis — you can see exactly what a package will pull in before installing it. The local SQLite database means searches are instant without network access.

**What I already have:** nix commands (installed). nixard provides a visual TUI for package exploration that nix CLI lacks.

**Difference:** Visual TUI for package exploration with real closure analysis and local database. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix run github:manelinux/nixard` or `nix profile install github:manelinux/nixard`.

**Open Source:** Yes

**Maturity:** Active development, NixOS 26.05 compatible

**Recommendation:** HIGH — closure analysis and visual package exploration are unique

---

### 32. verynix (vx)

**What it is:** Run any version of any Nix package in one command.

**What it does:**
- `vx hugo-0.139.0 build` — resolves version, finds nixpkgs commit, runs it
- Uses Nixhub API for version resolution
- `vx hugo serve` — run any package version
- `vx --verbose` — show resolution details

**Why it's interesting:** vx solves the "which nixpkgs commit has this version?" problem. It's like `nix run` but with version resolution built in.

**What I already have:** nix run (installed). vx adds version resolution.

**Difference:** Automatic version resolution via Nixhub API. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix run github:mipmip/verynix`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — useful for testing specific package versions, but nix run covers most needs

---

### 33. nxv

**What it is:** Nix Version Index. A blazingly fast CLI for finding any version of any Nix package.

**What it does:**
- Fast search (Bloom filter + SQLite FTS5)
- Version history — when each version was introduced
- CLI, HTTP API server with web UI, or remote API
- NixOS module (systemd service with automatic index updates)
- ~10MB static binary, ~190MB compressed index
- 9+ years of nixpkgs history
- Agent Skills-standard skill for AI coding agents
- Shell completions for bash, zsh, fish

**Why it's interesting:** nxv indexes the entire history of nixpkgs packages. The agent skills integration means AI coding agents can use it natively. The HTTP API + web UI is a nice touch.

**What I already have:** nix search (installed but slow, no history). nxv provides instant version history search.

**Difference:** Complete nixpkgs version history index with instant search. AI agent skills.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nxv` binary or `nix run`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — useful for package version discovery, but nix search covers basic needs

---

### 34. super-comma (,)

**What it is:** Instant Nix Runner (Rust). Ultra-fast, zero-dependency Nix command runner powered by nixpkgs-multiverse.

**What it does:**
- `, ripgrep -i "pattern"` — runs binaries directly via nix run
- `,s hello cowsay` — interactive shell with multiple packages
- `,v python3` — dynamically lists all historical versions
- Version constraints: `nodejs@20`, `python3."3.8.9"`
- Custom flake URIs: `f=github:ksv/repo1#tool`
- `--sandbox` mode with landrun
- `--nom` for nix-output-monitor progress bars
- Cross-platform sandboxing (Linux landrun, macOS sandbox-exec)

**Why it's interesting:** The comma-based command syntax is the fastest way to run Nix packages. The sandboxing and version constraints are powerful. The nixpkgs-multiverse backend gives access to all historical versions.

**What I already have:** nix run (installed). super-comma provides a faster syntax and version resolution.

**Difference:** Ultra-fast syntax, version resolution, sandboxing. But nix run covers most needs.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix profile install github:sayavc/super-comma-nix` or `cargo install`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — fast Nix runner but nix run already works

---

### 35. nixy

**What it is:** Simple Nix package manager (Rust). asdf/Homebrew alternative using Nix.

**What it does:**
- `nixy install ripgrep` — install with version constraints
- `nixy list` — see installed packages with versions
- `nixy search python` — find packages + versions
- `nixy profile` — interactive TUI profile selector
- Declarative `nixy.json` configuration
- Sync across machines via `nixy sync`
- Profile support (work, personal)
- Tab completion for zsh/bash

**Why it is interesting:** nixy provides a simple CLI interface for Nix packages, similar to Homebrew/asdf. The profile system and declarative config make it easy to manage packages across machines.

**What I already have:** nix profile (installed). nixy provides a simpler interface and profile management.

**Difference:** Simple CLI interface + profile management + declarative config. But nix profile already works.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix profile install github:yusukeshib/nixy`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — simpler Nix package management but nix profile already works

---

### 36. nix-pretty

**What it is:** Convert bloated nix path prefix to nix: in your terminal output. A Rust wrapper that collapses `/nix/store/...` paths into human-readable `nix:package-name/path`.

**What it does:**
- Rewrites shell output in real-time
- Collapses `/nix/store/hash-package-name/path` → `nix:package-name/path`
- Runs shell in PTY, forwards stdin, rewrites output
- Works with any shell, any tool
- `shell.nix` integration hook

**Why it's interesting:** This is a pure output-rewriting tool that makes Nix's verbose store paths readable. It's a small utility with a big UX impact.

**What I already have:** nix (installed) with verbose store paths. nix-pretty cleans up the output.

**Difference:** Real-time output rewriting for Nix store paths. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install nix-pretty` or `nix-build`.

**Open Source:** Yes

**Maturity:** Stable

**Recommendation:** LOW — nice UX improvement but not essential

---

### 37. niux

**What it is:** Declarative NixOS/home-manager CLI package manager written in Rust.

**What it does:**
- `niux -Hi firefox` — install for home
- `niux -Si vim` — install for system
- Automates configuration rebuilds
- Built-in generation diffing via nvd integration
- Autocompletion like Pacman/apt
- Supports both standalone and module home-manager

**Why it's interesting:** Similar to nixy but with a different approach. The `-H` (home) and `-S` (system) flags are intuitive.

**What I already have:** nix profile, home-manager. niux provides a simpler CLI.

**Difference:** Simple CLI with home/system distinction. But nix profile + home-manager already work.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix profile install github:sayavc/niux`.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** LOW — nix profile + home-manager already cover this

---

## ✍️ Text / Unicode

### 38. coretilus

**What it is:** A playful reimagining of GNU coreutils — a collection of tiny, silly, and sometimes useless command-line tools.

**What it does:**
- `sl` — Steam Locomotive (rust port)
- `gti` — "Start your engine!" before committing
- `pc` — data deserves a grand tour of your 486
- `mr` — Land the rocket without crashing it
- `dog` — A Dog chasing a domain
- More planned: `grpe` (searches nothing), `adn` (more), `...yuor` (own ideas)

**Why it's interesting:** Pure fun. When you mistype `git` → `gti`, instead of an error, you get a steam locomotive animation. It's the "toy" category done right.

**What I already have:** Nothing comparable. No coreutils parody tools.

**Difference:** Pure fun, typo-triggered animations. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `cargo install coretilus` or `.deb`/`.rpm` packages.

**Open Source:** Yes (Apache-2.0)

**Maturity:** Early (v0.3.0)

**Recommendation:** LOW — pure fun toy, not essential

---

## 🛠 Unix Utilities

### 39. tuitab (already listed in TUI section)

Also relevant here as a data processing tool. Already covered.

---

## 🎲 Fun

### 40. nix-bonsai

**What it is:** A bonsai tree generator written in 100% pure Nix.

**What it does:**
- Live animation mode (watch tree grow in real-time)
- Print mode (static tree for terminal)
- Customizable seed, life, multiplier, animation speed
- ANSI colored output
- Entire algorithm in pure Nix expressions
- `nix run github:your-username/nix-bonsai -- --print`

**Why it's interesting:** This is a tree generator written ENTIRELY in Nix expressions. The RNG, tree growth algorithm, and ANSI rendering are all Nix code. It's a demonstration of Nix's computational capabilities.

**What I already have:** Nothing comparable. No terminal tree generator.

**Difference:** Pure Nix implementation. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via `nix run github:...`.

**Open Source:** Yes

**Maturity:** Early

**Recommendation:** LOW — fun but purely experimental

---

## 🌀 Weird / Experimental

### 41. boxxy

**What it is:** A self-improving Linux terminal powered by AI characters. Full terminal emulator with agentic AI layer (BoxxyClaw).

**What it does:**
- AI characters that read your terminal buffer, remember preferences, autonomously fix dependencies
- `Ctrl+/` to activate AI agent
- GTK4/Adwaita UI
- Headless terminal engine (boxxy-vte)
- Agentic intelligence layer (boxxy-claw)
- MCP support
- Characters, skills, toolbox

**Why it's interesting:** This is the most ambitious terminal project I found. It's not just a terminal — it's an AI-powered operating system inside your terminal. The agentic AI layer can autonomously manage your system.

**What I already have:** Nothing comparable. No AI-powered terminal emulator.

**Difference:** AI agentic terminal emulator. Completely new category.

**Installed:** NO

**NixOS:** Not in nixpkgs. Preview stage. Requires GTK 4.22 + libAdwaita 1.9.

**Open Source:** Yes

**Maturity:** Preview/early access

**Recommendation:** LOW — very early stage, requires specific GTK version, not production-ready

---

### 42. wibwob-dos

**What it is:** A terminal-native desktop shell where humans and AI agents share the same screen. Operating system that lives inside your terminal.

**What it does:**
- Window manager, menu bar, overlapping draggable windows
- 22+ microapps: drum machines, ant colony simulations, code editor, file manager
- AI agent (Wib & Wob) embedded as desktop citizen
- Control API on port 8099
- Microapp SDK with stacks, rows, grids, tabs, filterable lists
- Themes, hot-switchable
- Runs in any terminal with 256-colour and mouse support

**Why it's interesting:** This is a complete desktop environment inside a terminal. It's the most ambitious "terminal OS" project. The microapp ecosystem and AI agent integration are unique.

**What I already have:** Nothing comparable. No terminal desktop environment.

**Difference:** Complete terminal desktop OS with AI agent. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Requires Bun, terminal with 256-colour + mouse support.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** LOW — experimental, requires Bun, not production-ready

---

### 43. seance

**What it is:** A GTK4 terminal multiplexer for Linux that auto-detects Claude Code, Codex, and Pi sessions and tracks their status.

**What it does:**
- Auto-detects AI coding agent sessions (Claude Code, Codex, Pi)
- Tracks status (working, waiting for permission, idle) in sidebar
- Desktop notifications for permission requests and task completions
- GTK4 + libadwaita with blur/transparency
- GPU-accelerated terminal rendering via libghostty
- Horizontal strip layout (niri-inspired)
- `seance ctl` API for scripting
- Workspaces, session persistence, tabs within columns
- AI agent skill file for `seance ctl` API

**Why it's interesting:** This is specifically designed for managing AI coding agent sessions. The auto-detection of Claude Code/Codex/Pi and status tracking is unique.

**What I already have:** tmux (installed), but no AI agent session management.

**Difference:** AI agent session management with auto-detection and status tracking. No equivalent.

**Installed:** NO

**NixOS:** Not in nixpkgs. Available via flake, AUR, or AppImage. Requires Zig 0.15.2+, GTK4, OpenGL 4.3+.

**Open Source:** Yes

**Maturity:** Active development

**Recommendation:** MEDIUM — useful for AI agent management but requires specific dependencies

---

### 44. claurst

**What it is:** Open-source, multi-provider terminal coding agent built in Rust. Clean-room reimplementation of Claude Code's behavior.

**What it does:**
- Multi-provider support (Claude, OpenAI, etc.)
- TUI pair programmer with rich UI
- Plugin system
- Companion named Rustle
- Chat forking, memory consolidation
- Agent Client Protocol (ACP) integration
- `/share` to share sessions via GitHub Gists
- `/goal` for sustained multi-turn objectives
- `ultracode` — highest effort level with subagents
- Voice/microphone support

**Why it's interesting:** This is a Claude Code alternative that runs in your terminal. The multi-provider support and ACP integration make it flexible.

**What I already have:** AI CLI tools (opencode, claude-code, lilo-code) already added as npm comments in tools.nix. claurst is a terminal-based alternative.

**Difference:** Terminal-based AI coding agent with multi-provider support. But AI tools already in config as npm comments.

**Installed:** NO (AI tools are npm comments, not installed)

**NixOS:** Not in nixpkgs. Available via `npm install -g claurst` or `cargo install`.

**Open Source:** Yes (MIT)

**Maturity:** Beta v0.1.7

**Recommendation:** MEDIUM — terminal AI coding agent, but AI tools already planned as npm installs

---

## Already Installed — Potentially Underused

### chafa

**What it already does:** ANSI/Unicode/Sixel terminal image rendering.

**What you might not be using:**
- Animated GIF rendering (`chafa --animate`)
- Python/JS bindings for embedding
- Terminal capability detection
- Multiple symbol sets (block, half-block, braille, etc.)
- Sixel protocol output for supported terminals

**Suggestion:** Check if `chafa --animate` is being used for animated content. The Python bindings could be integrated into scripts.

---

### ImageMagick

**What it already does:** Image conversion, manipulation, composition.

**What you might not be using:**
- `convert` for terminal-compatible output generation
- `magick` for batch processing
- `compare` for diffing images
- `identify` for metadata extraction
- `montage` for image grids
- `display` (if X11 available)

**Suggestion:** ImageMagick's `convert` can generate ANSI-compatible output. Combined with chafa, it's a powerful image processing pipeline.

---

### ffmpeg_7

**What it already does:** Video/audio processing.

**What you might not be using:**
- `ffmpeg` for generating terminal-compatible video frames
- `ffprobe` for metadata extraction
- `ffmpeg` filters for creating ASCII art from video
- Streaming to terminal via `ffmpeg -f rawvideo`

**Suggestion:** ffmpeg can pipe video frames to chafa or other terminal renderers for terminal video playback.

---

### neovim

**What it already does:** Modal text editor with LSP, treesitter, lazy.nvim.

**What you might not be using:**
- `nvim` as a terminal IDE (with lazyide-style features)
- Terminal integration via `:term`
- `nvim-treesitter` for syntax-aware terminal rendering
- Neovim as a markdown/terminal previewer

**Suggestion:** Neovim's `:term` command can replace many terminal tools. The treesitter integration could power terminal previews.

---

### yazi

**What it already does:** Terminal file manager with async I/O, previews, sixel/kitty image rendering.

**What you might not be using:**
- The `magick` plugin for ImageMagick integration
- The `video` previewer for ffmpeg-based video previews
- The `pdf` previewer for PDF inspection
- The `font` previewer for font inspection
- The `git` fetcher for repository info
- Custom opener rules for specialized workflows

**Suggestion:** Yazi's plugin system is extensive. The `magick` and `video` previewers are particularly underused.

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
| chafa | Animated GIF rendering, Python bindings | Try `chafa --animate`, use Python API |
| ImageMagick | Terminal-compatible output, montage | `magick convert` for ANSI output |
| ffmpeg_7 | Terminal video playback via frame piping | `ffmpeg -f rawvideo | chafa` |
| yazi | magick/video/pdf previewers | Enable `magick` and `video` previewers |
| neovim | `:term` command, treesitter previews | Use nvim as terminal IDE |

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
