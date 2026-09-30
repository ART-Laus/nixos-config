# home/features/desktop/orpheus/mounts/library — локальный HDD-маунт для библиотеки
# На newbox музыкальная библиотека (600 ГБ) живёт на локальном HDD 2 ТБ
# (/mnt/data, см. hosts/newbox/hardware-configuration.nix).
# Биндим /mnt/data/Music → /home/artlaus/Music, чтобы docker-compose Orpheus
# (Navidrome/FileBrowser) продолжал смотреть в привычный путь.
{ config, pkgs, lib, ... }:
{
  # SMB-клиент оставлен на случай старой схемы «библиотека на ноутбуке»
  home.packages = with pkgs; [
    cifs-utils
  ];

  # Системный сервис: bind-mount локального диска в /home/artlaus/Music
  systemd.user.services.orpheus-library-mount = {
    Unit = {
      Description = "Bind Project Orpheus music library from local HDD";
      After = [ "local-fs.target" ];
      Wants = [ "local-fs.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/artlaus/Music";
      ExecStart = "${pkgs.util-linux}/bin/mount --bind /mnt/data/Music /home/artlaus/Music";
      ExecStop = "${pkgs.coreutils}/bin/umount /home/artlaus/Music 2>/dev/null || true";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Альтернатива на ноутбуке (если библиотека ещё на SMB-шаре):
  # systemd.user.services.orpheus-library-mount: заменить ExecStart на
  #   ${pkgs.cifs-utils}/bin/mount -t cifs //LAPTOP-HOST/E$/Library /home/artlaus/Music \
  #     -o credentials=/home/artlaus/.config/orpheus/smb-credentials,vers=3.0,uid=1000,gid=1000,_netdev
}