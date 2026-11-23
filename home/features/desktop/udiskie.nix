{ ... }:
{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
    settings.device_config = [
      {
        id_uuid = "585444B7544499A0";
        options = [ "rw" "uid=1001" "gid=100" "dmask=0000" "fmask=0000" ];
      }
    ];
  };
}
