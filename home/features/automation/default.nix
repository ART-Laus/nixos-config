# home/features/automation/default.nix — слой бытовой автоматизации
{ config, pkgs, lib, ... }:

let
  scripts = import ../../../../scripts { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    scripts.extract
    scripts.archive
    scripts.fileinfo
    scripts.share
    scripts.doctor
    scripts.nixcheck
    scripts.make-qr
    scripts.clip-ocr
    scripts.tidy-downloads
    scripts.img-resize
    scripts.img-compress
    scripts.vid2audio
    scripts.vid2gif
    scripts.pdf2text
    scripts.batch-rename
    scripts.find-duplicates
    scripts.hashfile
  ];

  # Алиасы для скриптов
  programs.zsh.shellAliases = {
    ex = "extract";
    ar = "archive";
    fi = "fileinfo";
    sh = "share";
    dc = "doctor";
    nc = "nixcheck";
    qr = "make-qr";
    oc = "clip-ocr";
    td = "tidy-downloads";
    ir = "img-resize";
    ic = "img-compress";
    va = "vid2audio";
    vg = "vid2gif";
    pt = "pdf2text";
    br = "batch-rename";
    fd = "find-duplicates";
    hf = "hashfile";
  };
}
