# home/features/desktop/orpheus/mounts/library — SMB mount для библиотеки с ноутбука
# Создаёт точку монтирования /home/artlaus/Music для E:/Library с ноутбука через Tailscale.
# Настройка требует IP/хостнейм ноутбука и SMB-учётных данных.
# Замените LAPTOP-HOST на реальный хостнейм или IP ноутбука в Tailscale.
{ config, pkgs, lib, ... }:
{
  # Установка SMB-клиентских инструментов
  home.packages = with pkgs; [
    cifs-utils
  ];

  # Файл учётных данных SMB
  home.file.".config/orpheus/smb-credentials".text = ''
    # SMB credentials for laptop
    # Замените на реальные данные
    username=YOUR_USERNAME
    password=YOUR_PASSWORD
    domain=WORKGROUP
  '';

  # Системный сервис для монтирования библиотеки
  systemd.user.services.orpheus-library-mount = {
    Unit = {
      Description = "Mount Project Orpheus music library from laptop";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p /home/artlaus/Music";
      ExecStartPost = "${pkgs.cifs-utils}/bin/mount -t cifs //LAPTOP-HOST/E$/Library /home/artlaus/Music -o credentials=/home/artlaus/.config/orpheus/smb-credentials,vers=3.0,uid=1000,gid=1000,file_mode=0644,dir_mode=0755,_netdev";
      ExecStop = "${pkgs.coreutils}/bin/umount /home/artlaus/Music 2>/dev/null || true";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Символическая ссылка на библиотеку для docker-compose
  home.file.".config/orpheus/library-symlink".text = ''
    # Для docker-compose создайте symlink:
    # ln -sf /home/artlaus/Music /home/artlaus/nixos-config/home/features/desktop/orpheus/mounts/library
    #
    # Или используйте переменную окружения:
    # export ORPHEUS_MUSIC_DIR=/home/artlaus/Music
  '';
}
