# scripts/default.nix — все кастомные скрипты
# Каждый скрипт — реальный файл в scripts/, упакованный через writeShellScriptBin
{ pkgs, lib, ... }:

let
  readScript = name: builtins.readFile ./${name};
in
{
  # ── Старые скрипты ──
  rofi-scripts = pkgs.writeShellScriptBin "rofi-scripts" (readScript "rofi-scripts.sh") {
    runtimeInputs = with pkgs; [ rofi ];
  };

  wallpaper = pkgs.writeShellScriptBin "wallpaper" (readScript "wallpaper.sh") {
    runtimeInputs = with pkgs; [ hyprctl hyprpaper ];
  };

  rofi-image = pkgs.writeShellScriptBin "rofi-image" (readScript "media/rofi-image.sh") {
    runtimeInputs = with pkgs; [ rofi imagemagick libnotify fd ];
  };

  rofi-video = pkgs.writeShellScriptBin "rofi-video" (readScript "media/rofi-video.sh") {
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  rofi-audio = pkgs.writeShellScriptBin "rofi-audio" (readScript "media/rofi-audio.sh") {
    runtimeInputs = with pkgs; [ rofi ffmpeg_7 libnotify fd ];
  };

  # ── Архивы ──
  extract = pkgs.writeShellScriptBin "extract" (readScript "extract") {
    runtimeInputs = with pkgs; [ unzip unrar p7zip tar zstd xz lzma ];
  };

  archive = pkgs.writeShellScriptBin "archive" (readScript "archive") {
    runtimeInputs = with pkgs; [ zip tar zstd xz lzma unrar p7zip ];
  };

  # ── Файлы ──
  fileinfo = pkgs.writeShellScriptBin "fileinfo" (readScript "fileinfo") {
    runtimeInputs = with pkgs; [ file exiftool ];
  };

  hashfile = pkgs.writeShellScriptBin "hashfile" (readScript "hashfile") {
    runtimeInputs = with pkgs; [ ];
  };

  # ── Share ──
  share = pkgs.writeShellScriptBin "share" (readScript "share") {
    runtimeInputs = with pkgs; [ python3Full ];
  };

  # ── Система ──
  doctor = pkgs.writeShellScriptBin "doctor" (readScript "doctor") {
    runtimeInputs = with pkgs; [ ];
  };

  # ── Nix ──
  nixcheck = pkgs.writeShellScriptBin "nixcheck" (readScript "nixcheck") {
    runtimeInputs = with pkgs; [ nix nixpkgs-fmt ];
  };

  # ── QR ──
  make-qr = pkgs.writeShellScriptBin "make-qr" (readScript "make-qr") {
    runtimeInputs = with pkgs; [ qrencode ];
  };

  # ── Clipboard ──
  clip-ocr = pkgs.writeShellScriptBin "clip-ocr" (readScript "clip-ocr") {
    runtimeInputs = with pkgs; [ wl-clipboard tesseract ];
  };

  # ── Downloads ──
  tidy-downloads = pkgs.writeShellScriptBin "tidy-downloads" (readScript "tidy-downloads") {
    runtimeInputs = with pkgs; [ fd ];
  };

  # ── Изображения ──
  img-resize = pkgs.writeShellScriptBin "img-resize" (readScript "img-resize") {
    runtimeInputs = with pkgs; [ imagemagick ];
  };

  img-compress = pkgs.writeShellScriptBin "img-compress" (readScript "img-compress") {
    runtimeInputs = with pkgs; [ imagemagick optipng pngquant jpegoptim gifsicle ];
  };

  # ── Видео ──
  vid2audio = pkgs.writeShellScriptBin "vid2audio" (readScript "vid2audio") {
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
  };

  vid2gif = pkgs.writeShellScriptBin "vid2gif" (readScript "vid2gif") {
    runtimeInputs = with pkgs; [ ffmpeg_7 ];
  };

  # ── PDF ──
  pdf2text = pkgs.writeShellScriptBin "pdf2text" (readScript "pdf2text") {
    runtimeInputs = with pkgs; [ poppler_utils ];
  };

  # ── Переименование ──
  batch-rename = pkgs.writeShellScriptBin "batch-rename" (readScript "batch-rename") {
    runtimeInputs = with pkgs; [ ];
  };

  # ── Дубликаты ──
  find-duplicates = pkgs.writeShellScriptBin "find-duplicates" (readScript "find-duplicates") {
    runtimeInputs = with pkgs; [ fdupes ];
  };
}
