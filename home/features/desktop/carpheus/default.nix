{ lib, ... }:
let
  envText = lib.concatStringsSep "\n" [
    "CARPPHEUS_NAVIDROME_URL=http://localhost:4533"
    "CARPPHEUS_NAVIDROME_USER="
    "CARPPHEUS_NAVIDROME_PASSWORD="
  ] + "\n";
in
{
  imports = [ ./daemon.nix ];

  orpheus.daemon.enable = true;

  home.activation.carpheusConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/carpheus"
    mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/carpheus/artwork"
    if [[ ! -e "$HOME/.config/carpheus/navidrome.env" ]]; then
      umask 077
      printf '%s' ${lib.escapeShellArg envText} > "$HOME/.config/carpheus/navidrome.env"
      chmod 600 "$HOME/.config/carpheus/navidrome.env"
    fi
  '';
}
