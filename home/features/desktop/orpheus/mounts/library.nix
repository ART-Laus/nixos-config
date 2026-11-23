{ pkgs, ... }:
let
  prepareScript = pkgs.writeShellScript "orpheus-library-prepare" ''
    set -eu
    disk='/run/media/artlaus/Юркин 1ТА'
    src="$disk/Library"
    dev=/dev/disk/by-uuid/585444B7544499A0
    if ! ${pkgs.util-linux}/bin/mountpoint -q "$disk"; then
      ${pkgs.udisks2}/bin/udisksctl mount -b "$dev" --options ro || true
    fi
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
      After = [ "local-fs.target" "udiskie.service" ];
      Wants = [ "local-fs.target" "udiskie.service" ];
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
      PathExists = "/run/media/artlaus/Юркин 1ТА/Library";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
