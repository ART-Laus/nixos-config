{ pkgs, ... }:
{
  services.swayidle = {
    enable = false;
    events = { };
    timeouts = [ ];
  };
}
