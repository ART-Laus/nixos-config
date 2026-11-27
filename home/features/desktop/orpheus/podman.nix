{ config, pkgs, ... }:
let
  dataDir = "${config.home.homeDirectory}/.local/share/orpheus";
  podman = "${pkgs.podman}/bin/podman";
in
{
  systemd.user.services.orpheus-navidrome = {
    Unit = {
      Description = "Project Orpheus Navidrome Music Server";
      After = [ "orpheus-library-mount.service" ];
      Wants = [ "orpheus-library-mount.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 600;
      ExecStart = "${podman} run -d --name orpheus-navidrome --replace --restart unless-stopped --pull=never --log-driver journald -p 4533:4533 -v \"/mnt/Юркин-1ТА/Library:/music:ro\" -v ${dataDir}/navidrome:/data -e ND_MUSICFOLDER=/music -e ND_DATAFOLDER=/data -e ND_CONFIGFILE=/data/navidrome.toml -e ND_PORT=4533 -e ND_ENABLESTARRATING=true -e ND_ENABLEEXTERNAL=true -e ND_SCANSCHEDULE='@every 5m' docker.io/deluan/navidrome:latest";
      ExecStop = "${pkgs.bash}/bin/bash -c '${podman} stop orpheus-navidrome; ${podman} rm orpheus-navidrome'";
    };
  };

  systemd.user.services.orpheus-filebrowser = {
    Unit = {
      Description = "Project Orpheus FileBrowser";
      After = [ "orpheus-library-mount.service" ];
      Wants = [ "orpheus-library-mount.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 600;
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${dataDir}/filebrowser/srv";
      ExecStart = "${podman} run -d --name orpheus-filebrowser --replace --restart unless-stopped --pull=never --log-driver journald --user 0:0 -p 8080:80 -v ${dataDir}/filebrowser/config:/config -v ${dataDir}/filebrowser/database:/database -v ${dataDir}/filebrowser/srv:/srv -v \"/mnt/Юркин-1ТА/Library:/srv/Music:ro\" -e UID=1001 -e GID=100 docker.io/filebrowser/filebrowser:latest";
      ExecStop = "${pkgs.bash}/bin/bash -c '${podman} stop orpheus-filebrowser; ${podman} rm orpheus-filebrowser'";
    };
  };
}
