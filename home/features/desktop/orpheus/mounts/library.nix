{ pkgs, ... }:
let
  prepareScript = pkgs.writeShellScript "orpheus-library-prepare" ''
    set -eu
    disk='/mnt/Юркин-1ТА'
    src="$disk/Library"
    # Диск монтируется системой через fileSystems в fstab — ждём появления Library.
    for i in {1..30}; do
      if [ -d "$src" ]; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
  '';
in
{
  home.packages = with pkgs; [
    cifs-utils
  ];

  systemd.user.services.orpheus-library-mount = {
    Unit = {
      Description = "Prepare external Project Orpheus music library";
      After = [ "local-fs.target" ];
      Wants = [ "local-fs.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${prepareScript}";
    };
  };

  systemd.user.paths.orpheus-library-mount = {
    Unit = {
      Description = "Watch for external Project Orpheus music library";
    };
    Path = {
      PathExists = "/mnt/Юркин-1ТА/Library";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
