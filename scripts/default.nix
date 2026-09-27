# scripts/default.nix — все кастомные скрипты
{ pkgs, lib, ... }:

let
  binPath = pkgs.lib.makeBinPath;
  scriptsSrc = ./.;
in
{
  # ── Старые скрипты (из файлов) ──
  rofi-scripts = pkgs.writeShellScriptBin "rofi-scripts" ''
    #!/usr/bin/env bash
    set -euo pipefail
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    MEDIA_SCRIPTS_DIR="$SCRIPTS_DIR/media"
    if [[ ! -d "$MEDIA_SCRIPTS_DIR" ]]; then
        rofi -e "Error: Media scripts directory not found"
        exit 1
    fi
    options="🖼️ Image\n🎥 Video\n🎵 Audio"
    selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Select media type")
    case "$selected_option" in
        "🖼️ Image") rofi-image ;;
        "🎥 Video") rofi-video ;;
        "🎵 Audio") rofi-audio ;;
        *) exit 0 ;;
    esac
  '' {
    runtimeInputs = with pkgs; [ rofi ];
  };

  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    #!/usr/bin/env bash
    WALLPAPER_DIR="/home/artlaus/nixos-config/home/features/desktop/wallpapers"
    IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.avif" \) | shuf -n 1)
    if [ -n "$IMAGE" ]; then
      hyprctl hyprpaper wallpaper ",$IMAGE"
    fi
  '' {
    runtimeInputs = with pkgs; [ hyprctl hyprpaper ];
  };

  rofi-image = pkgs.writeShellScriptBin "rofi-image" (builtins.readFile ./media/rofi-image.sh) {
    runtimeInputs = with pkgs; [ rofi imagemagick libnotify fd ];
  };

  rofi-video = pkgs.writeShellScriptBin "rofi-video" (builtins.readFile ./media/rofi-video.sh) {
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  rofi-audio = pkgs.writeShellScriptBin "rofi-audio" (builtins.readFile ./media/rofi-audio.sh) {
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  # ── Новые скрипты (writeShellApplication) ──
  extract = pkgs.writeShellApplication {
    name = "extract";
    runtimeInputs = with pkgs; [ unzip unrar p7zip tar zstd xz lzma ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      extract() {
        local archive="$1"
        case "$archive" in
          *.zip) unzip "$archive" -d "${archive%.zip}" ;;
          *.tar.gz|*.tgz) tar xzf "$archive" -d "${archive%.tar.gz}" ;;
          *.tar.bz2|*.tbz2) tar xjf "$archive" -d "${archive%.tar.bz2}" ;;
          *.tar.xz|*.txz) tar xJf "$archive" -d "${archive%.tar.xz}" ;;
          *.tar.zst) tar --zstd -xf "$archive" -d "${archive%.tar.zst}" ;;
          *.tar.lzma) tar --lzma -xf "$archive" -d "${archive%.tar.lzma}" ;;
          *.rar) unrar x "$archive" "${archive%.rar}/" ;;
          *.7z) 7z x "$archive" -o"${archive%.7z}" ;;
          *.gz) gunzip "$archive" ;;
          *.bz2) bunzip2 "$archive" ;;
          *.xz) unxz "$archive" ;;
          *.zst) zstd -d "$archive" ;;
          *) echo "Unknown archive format: $archive" >&2; exit 1 ;;
        esac
      }
      if [ $# -eq 0 ]; then echo "Usage: extract <archive...>" >&2; exit 1; fi
      for archive in "$@"; do
        [ -f "$archive" ] || { echo "File not found: $archive" >&2; continue; }
        echo "Extracting: $archive"
        extract "$archive"
      done
    '';
  };

  archive = pkgs.writeShellApplication {
    name = "archive";
    runtimeInputs = with pkgs; [ zip tar zstd xz lzma unrar p7zip ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: archive <output> <files...>" >&2; exit 1; fi
      local output="$1"; shift
      case "$output" in
        *.zip) zip "$output" "$@" ;;
        *.tar.gz|*.tgz) tar czf "$output" "$@" ;;
        *.tar.bz2|*.tbz2) tar cjf "$output" "$@" ;;
        *.tar.xz|*.txz) tar cJf "$output" "$@" ;;
        *.tar.zst) tar --zstd -cf "$output" "$@" ;;
        *.tar.lzma) tar --lzma -cf "$output" "$@" ;;
        *.rar) rar a "$output" "$@" ;;
        *.7z) 7z a "$output" "$@" ;;
        *) echo "Unknown archive format: $output" >&2; exit 1 ;;
      esac
    '';
  };

  fileinfo = pkgs.writeShellApplication {
    name = "fileinfo";
    runtimeInputs = with pkgs; [ file exiftool ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -eq 0 ]; then echo "Usage: fileinfo <file...>" >&2; exit 1; fi
      for f in "$@"; do
        [ -e "$f" ] || { echo "Not found: $f" >&2; continue; }
        echo "=== $(basename "$f") ==="
        file "$f"
        echo "Size: $(du -sh "$f" 2>/dev/null | cut -f1)"
        echo "SHA256: $(sha256sum "$f" 2>/dev/null | cut -d' ' -f1)"
        echo "Modified: $(stat -c '%y' "$f" 2>/dev/null)"
        exiftool "$f" 2>/dev/null | head -20
        echo ""
      done
    '';
  };

  hashfile = pkgs.writeShellApplication {
    name = "hashfile";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -eq 0 ]; then echo "Usage: hashfile <file...>" >&2; exit 1; fi
      for f in "$@"; do
        [ -f "$f" ] || { echo "Not found: $f" >&2; continue; }
        echo "$(basename "$f"): $(sha256sum "$f" | cut -d' ' -f1)"
      done
    '';
  };

  share = pkgs.writeShellApplication {
    name = "share";
    runtimeInputs = with pkgs; [ python3Full ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      PORT="${1:-8080}"
      DIR="${2:-.}"
      if [ ! -d "$DIR" ]; then echo "Directory not found: $DIR" >&2; exit 1; fi
      echo "Serving $DIR on http://localhost:$PORT"
      echo "Press Ctrl+C to stop."
      cd "$DIR"
      python3 -m http.server "$PORT"
    '';
  };

  doctor = pkgs.writeShellApplication {
    name = "doctor";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      echo "=== System Doctor ==="
      echo ""
      echo "--- Nix ---"
      nix --version 2>/dev/null || echo "Nix not found"
      nix flake check 2>&1 | tail -5 || echo "Flake check failed"
      echo ""
      echo "--- Home Manager ---"
      home-manager --version 2>/dev/null || echo "home-manager not found"
      echo ""
      echo "--- Systemd ---"
      systemctl --failed 2>/dev/null || echo "No failed services"
      echo ""
      echo "--- Disk ---"
      df -h / 2>/dev/null || echo "df failed"
      echo ""
      echo "--- Memory ---"
      free -h 2>/dev/null || echo "free failed"
      echo ""
      echo "--- GPU ---"
      lspci | grep -i vga 2>/dev/null || echo "GPU not detected"
      echo ""
      echo "--- Audio ---"
      pactl info 2>/dev/null | grep "Server Name" || echo "PipeWire not found"
      echo ""
      echo "--- Network ---"
      ip addr show 2>/dev/null | head -20 || echo "ip failed"
      echo ""
      echo "--- DNS ---"
      resolvectl status 2>/dev/null | head -10 || echo "resolvectl failed"
      echo ""
      echo "--- Wayland ---"
      echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"
      echo ""
      echo "--- Broken symlinks ---"
      find /home/artlaus -xtype l 2>/dev/null | head -20 || echo "No broken symlinks"
      echo ""
      echo "--- Missing binaries ---"
      for cmd in ffmpeg imagemagick jq fd ripgrep; do
        command -v "$cmd" >/dev/null 2>&1 && echo "✓ $cmd" || echo "✗ $cmd"
      done
      echo ""
      echo "=== Doctor complete ==="
    '';
  };

  nixcheck = pkgs.writeShellApplication {
    name = "nixcheck";
    runtimeInputs = with pkgs; [ nix nixpkgs-fmt ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -eq 0 ]; then
        echo "Usage: nixcheck [flake|build|eval|format|switch|generations|gc|search]" >&2
        exit 1
      fi
      case "$1" in
        flake) nix flake check ;;
        build) shift; nix build ".#$@" ;;
        eval) shift; nix eval ".#$@" ;;
        format) nixpkgs-fmt flake.nix ;;
        generations) nixos-rebuild list ;;
        gc) nix-collect-garbage -d ;;
        search) shift; nix search nixpkgs "$@" ;;
        *) echo "Unknown command: $1" >&2; exit 1 ;;
      esac
    '';
  };

  make-qr = pkgs.writeShellApplication {
    name = "make-qr";
    runtimeInputs = with pkgs; [ qrencode ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -eq 0 ]; then echo "Usage: make-qr <text|url> [output.png]" >&2; exit 1; fi
      TEXT="$1"
      OUTPUT="${2:-qr.png}"
      qrencode -o "$OUTPUT" -s 10 "$TEXT"
      echo "QR code saved to: $OUTPUT"
    '';
  };

  clip-ocr = pkgs.writeShellApplication {
    name = "clip-ocr";
    runtimeInputs = with pkgs; [ wl-clipboard tesseract ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if ! command -v wl-paste &>/dev/null; then echo "wl-paste not found." >&2; exit 1; fi
      if ! command -v tesseract &>/dev/null; then echo "tesseract not found." >&2; exit 1; fi
      TEMP=$(mktemp /tmp/clip-ocr.XXXXXX.png)
      wl-paste -t image/png > "$TEMP"
      echo "OCR result:"
      tesseract "$TEMP" - 2>/dev/null
      rm -f "$TEMP"
    '';
  };

  tidy-downloads = pkgs.writeShellApplication {
    name = "tidy-downloads";
    runtimeInputs = with pkgs; [ fd ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      DOWNLOADS_DIR="${1:-$HOME/Downloads}"
      if [ ! -d "$DOWNLOADS_DIR" ]; then echo "Directory not found: $DOWNLOADS_DIR" >&2; exit 1; fi
      echo "=== Downloads Analysis ==="
      echo "Directory: $DOWNLOADS_DIR"
      echo ""
      echo "--- Images ---"
      find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.avif" \) -printf "%f\n" 2>/dev/null | head -20
      echo ""
      echo "--- Videos ---"
      find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.avi" \) -printf "%f\n" 2>/dev/null | head -20
      echo ""
      echo "--- Archives ---"
      find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" -o -name "*.rar" \) -printf "%f\n" 2>/dev/null | head -20
      echo ""
      echo "--- Documents ---"
      find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.pdf" -o -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" \) -printf "%f\n" 2>/dev/null | head -20
      echo ""
      echo "--- Audio ---"
      find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.ogg" -o -name "*.wav" \) -printf "%f\n" 2>/dev/null | head -20
      echo ""
      echo "--- Total files: $(find "$DOWNLOADS_DIR" -maxdepth 1 -type f | wc -l) ---"
      echo "Dry run. No files moved."
    '';
  };

  img-resize = pkgs.writeShellApplication {
    name = "img-resize";
    runtimeInputs = with pkgs; [ imagemagick ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: img-resize <file> <geometry>" >&2; exit 1; fi
      FILE="$1"; GEOMETRY="$2"
      [ -f "$FILE" ] || { echo "File not found: $FILE" >&2; exit 1; }
      OUTPUT="${FILE%.*}_resize.${FILE##*.}"
      convert "$FILE" -resize "$GEOMETRY" "$OUTPUT"
      echo "Resized: $FILE → $OUTPUT ($GEOMETRY)"
    '';
  };

  img-compress = pkgs.writeShellApplication {
    name = "img-compress";
    runtimeInputs = with pkgs; [ imagemagick optipng pngquant jpegoptim gifsicle ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -eq 0 ]; then echo "Usage: img-compress <file...>" >&2; exit 1; fi
      for f in "$@"; do
        [ -f "$f" ] || { echo "Not found: $f" >&2; continue; }
        EXT="${f##*.}"
        case "$EXT" in
          png) optipng -o7 "$f" 2>/dev/null && echo "Optimized: $f" || echo "Failed: $f" ;;
          jpg|jpeg) jpegoptim --strip-all "$f" 2>/dev/null && echo "Optimized: $f" || echo "Failed: $f" ;;
          gif) gifsicle -O3 "$f" -o "${f%.*}_opt.${f##*.}" 2>/dev/null && echo "Optimized: $f" || echo "Failed: $f" ;;
          *) echo "Unsupported format: $EXT" >&2 ;;
        esac
      done
    '';
  };

  vid2audio = pkgs.writeShellApplication {
    name = "vid2audio";
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: vid2audio <video> <output.mp3>" >&2; exit 1; fi
      VIDEO="$1"; OUTPUT="${2:-${VIDEO%.*}.mp3}"
      [ -f "$VIDEO" ] || { echo "Video not found: $VIDEO" >&2; exit 1; }
      ffmpeg -i "$VIDEO" -vn -acodec libmp3lame -q:a 2 "$OUTPUT"
      echo "Audio extracted: $VIDEO → $OUTPUT"
    '';
  };

  vid2gif = pkgs.writeShellApplication {
    name = "vid2gif";
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: vid2gif <video> <output.gif>" >&2; exit 1; fi
      VIDEO="$1"; OUTPUT="${2:-${VIDEO%.*}.gif}"
      [ -f "$VIDEO" ] || { echo "Video not found: $VIDEO" >&2; exit 1; }
      ffmpeg -i "$VIDEO" -vf "fps=15,scale=480:-1" -t 10 "$OUTPUT"
      echo "GIF created: $VIDEO → $OUTPUT"
    '';
  };

  pdf2text = pkgs.writeShellApplication {
    name = "pdf2text";
    runtimeInputs = with pkgs; [ poppler_utils ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: pdf2text <pdf> [output.txt]" >&2; exit 1; fi
      PDF="$1"; OUTPUT="${2:-${PDF%.pdf}.txt}"
      [ -f "$PDF" ] || { echo "PDF not found: $PDF" >&2; exit 1; }
      pdftotext "$PDF" "$OUTPUT"
      echo "Text extracted: $PDF → $OUTPUT"
    '';
  };

  batch-rename = pkgs.writeShellApplication {
    name = "batch-rename";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ $# -lt 2 ]; then echo "Usage: batch-rename <pattern> <replacement> <files...>" >&2; exit 1; fi
      PATTERN="$1"; REPLACEMENT="$2"; shift 2
      for f in "$@"; do
        [ -f "$f" ] || { echo "Not found: $f" >&2; continue; }
        NEW=$(echo "$f" | sed "s/$PATTERN/$REPLACEMENT/")
        if [ "$f" != "$NEW" ]; then
          mv "$f" "$NEW"
          echo "Renamed: $f → $NEW"
        fi
      done
    '';
  };

  find-duplicates = pkgs.writeShellApplication {
    name = "find-duplicates";
    runtimeInputs = with pkgs; [ fdupes ];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      DIR="${1:-.}"
      [ -d "$DIR" ] || { echo "Directory not found: $DIR" >&2; exit 1; }
      echo "Searching for duplicates in: $DIR"
      fdupes -r "$DIR"
    '';
  };
}
