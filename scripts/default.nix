# scripts/default.nix — все кастомные скрипты
# Каждый скрипт — реальный файл в scripts/, упакованный через writeShellApplication
# (writeShellApplication принимает runtimeInputs; writeShellScriptBin — нет)
{ pkgs, ... }:

let
  # Текст скрипта без shebang — writeShellApplication генерирует его сам
  readScript = name:
    let
      text = builtins.readFile ./${name};
    in
    builtins.replaceStrings [ (builtins.head (builtins.split "\n" text)) ] [ "" ] text;
in
{
  # ── Старые скрипты ──
  rofi-scripts = pkgs.writeShellApplication {
    name = "rofi-scripts";
    text = readScript "rofi-scripts.sh";
    runtimeInputs = with pkgs; [ rofi ];
  };

  wallpaper = pkgs.writeShellApplication {
    name = "wallpaper";
    text = readScript "wallpaper.sh";
    runtimeInputs = with pkgs; [ hyprland hyprpaper ];
  };

  rofi-image = pkgs.writeShellApplication {
    name = "rofi-image";
    text = readScript "media/rofi-image.sh";
    runtimeInputs = with pkgs; [ rofi imagemagick libnotify fd ];
  };

  rofi-video = pkgs.writeShellApplication {
    name = "rofi-video";
    text = readScript "media/rofi-video.sh";
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  rofi-audio = pkgs.writeShellApplication {
    name = "rofi-audio";
    text = readScript "media/rofi-audio.sh";
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  # ── Архивы ──
  extract = pkgs.writeShellApplication {
    name = "extract";
    text = readScript "extract";
    runtimeInputs = with pkgs; [ unzip unrar p7zip gnutar zstd xz ];
  };

  archive = pkgs.writeShellApplication {
    name = "archive";
    text = readScript "archive";
    runtimeInputs = with pkgs; [ zip gnutar zstd xz unrar p7zip ];
  };

  # ── Файлы ──
  fileinfo = pkgs.writeShellApplication {
    name = "fileinfo";
    text = readScript "fileinfo";
    runtimeInputs = with pkgs; [ file exiftool ];
  };

  hashfile = pkgs.writeShellApplication {
    name = "hashfile";
    text = readScript "hashfile";
    runtimeInputs = with pkgs; [ ];
  };

  # ── Share ──
  share = pkgs.writeShellApplication {
    name = "share";
    text = readScript "share";
    runtimeInputs = with pkgs; [ python3Full ];
  };

  # ── Система ──
  doctor = pkgs.writeShellApplication {
    name = "doctor";
    text = readScript "doctor";
    runtimeInputs = with pkgs; [ ];
  };

  # ── Nix ──
  nixcheck = pkgs.writeShellApplication {
    name = "nixcheck";
    text = readScript "nixcheck";
    runtimeInputs = with pkgs; [ nix nixpkgs-fmt ];
  };

  # ── QR ──
  make-qr = pkgs.writeShellApplication {
    name = "make-qr";
    text = readScript "make-qr";
    runtimeInputs = with pkgs; [ qrencode ];
  };

  # ── Clipboard ──
  clip-ocr = pkgs.writeShellApplication {
    name = "clip-ocr";
    text = readScript "clip-ocr";
    runtimeInputs = with pkgs; [ wl-clipboard tesseract ];
  };

  # ── Downloads ──
  tidy-downloads = pkgs.writeShellApplication {
    name = "tidy-downloads";
    text = readScript "tidy-downloads";
    runtimeInputs = with pkgs; [ fd ];
  };

  # ── Изображения ──
  img-resize = pkgs.writeShellApplication {
    name = "img-resize";
    text = readScript "img-resize";
    runtimeInputs = with pkgs; [ imagemagick ];
  };

  img-compress = pkgs.writeShellApplication {
    name = "img-compress";
    text = readScript "img-compress";
    runtimeInputs = with pkgs; [ imagemagick optipng pngquant jpegoptim gifsicle ];
  };

  # ── Видео ──
  vid2audio = pkgs.writeShellApplication {
    name = "vid2audio";
    text = readScript "vid2audio";
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
  };

  vid2gif = pkgs.writeShellApplication {
    name = "vid2gif";
    text = readScript "vid2gif";
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
  };

  # ── PDF ──
  pdf2text = pkgs.writeShellApplication {
    name = "pdf2text";
    text = readScript "pdf2text";
    runtimeInputs = with pkgs; [ poppler_utils ];
  };

  # ── Переименование ──
  batch-rename = pkgs.writeShellApplication {
    name = "batch-rename";
    text = readScript "batch-rename";
    runtimeInputs = with pkgs; [ ];
  };

  # ── Дубликаты ──
  find-duplicates = pkgs.writeShellApplication {
    name = "find-duplicates";
    text = readScript "find-duplicates";
    runtimeInputs = with pkgs; [ fdupes ];
  };

  # ── Графическое меню автоматизации ──
  automation-menu = pkgs.writeShellApplication {
    name = "automation-menu";
    text = readScript "automation-menu.sh";
    runtimeInputs = with pkgs; [ rofi ];
  };
}
