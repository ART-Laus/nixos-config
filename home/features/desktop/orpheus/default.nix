# home/features/desktop/orpheus/default.nix — Project Orpheus
# Настройка системы для работы с музыкальным проектом.
# Не изменяет сам проект — всё на уровне системы.
{ config, pkgs, lib, ... }:
{
  # Docker-сервисы (Navidrome, FileBrowser)
  imports = [
    ./docker-compose.nix
    ./mounts/library.nix
  ];

  # Python venv для проекта
  home.file.".config/orpheus/setup-venv".text = ''
    #!/bin/bash
    cd /home/artlaus/nixos-config/home/features/desktop/orpheus/project
    source .venv/bin/activate
    pip install -e .
    pip install spotipy pyyaml pycryptodome mutagen pytest
    echo "Venv ready. Use: source .venv/bin/activate && orpheus --help"
  '';

  # Документация
  home.file.".config/orpheus/README".text = ''
    Project Orpheus — быстрый старт
    ==============================

    1. Монтирование библиотеки:
       systemctl --user start orpheus-library-mount
       (Настройте /home/artlaus/.config/orpheus/smb-credentials)

    2. Docker-сервисы:
       systemctl --user start orpheus-navidrome
       systemctl --user start orpheus-filebrowser

    3. Доступ:
       Navidrome:  http://localhost:4533
       FileBrowser: http://localhost:8080

    4. Python проект:
       source .venv/bin/activate
       orpheus import
       orpheus status
  '';
}
