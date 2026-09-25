# home/features/desktop/orpheus/docker-compose.nix — Docker-сервисы Project Orpheus
# Запускает Navidrome и FileBrowser без изменения проекта.
# Использует /home/artlaus/Music как корень музыкальной библиотеки.
{ config, pkgs, lib, ... }:
{
  # Docker включён через features.virtualization.enable

  # Сервис Navidrome — музыкальный сервер
  systemd.user.services.orpheus-navidrome = {
    Unit = {
      Description = "Project Orpheus Navidrome Music Server";
      After = [ "docker.service" ];
      Requires = [ "docker.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker run -d --name orpheus-navidrome --restart unless-stopped -p 4533:4533 -v /home/artlaus/Music:/music:ro -v /home/artlaus/nixos-config/home/features/desktop/orpheus/data/navidrome:/data -e ND_MUSICFOLDER=/music -e ND_DATAFOLDER=/data -e ND_ENABLESTARRATING=true -e ND_ENABLEEXTERNAL=true -e ND_SCANSCHEDULE='@every 5m' deluan/navidrome:latest";
      ExecStop = "${pkgs.docker}/bin/docker stop orpheus-navidrome && ${pkgs.docker}/bin/docker rm orpheus-navidrome";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Сервис FileBrowser — файловый менеджер
  systemd.user.services.orpheus-filebrowser = {
    Unit = {
      Description = "Project Orpheus FileBrowser";
      After = [ "docker.service" ];
      Requires = [ "docker.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker run -d --name orpheus-filebrowser --restart unless-stopped -p 8080:80 -v /home/artlaus/Music:/srv/Music -v /home/artlaus/nixos-config/home/features/desktop/orpheus/data/filebrowser.db:/database/filebrowser.db filebrowser/filebrowser:latest";
      ExecStop = "${pkgs.docker}/bin/docker stop orpheus-filebrowser && ${pkgs.docker}/bin/docker rm orpheus-filebrowser";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
