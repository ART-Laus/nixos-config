{ pkgs, lib, ... }:
let
  api = import ./scripts { inherit pkgs; };
  envText = lib.concatStringsSep "\n" [
    "CARPPHEUS_NAVIDROME_URL=http://localhost:4533"
    "CARPPHEUS_NAVIDROME_USER="
    "CARPPHEUS_NAVIDROME_PASSWORD="
    "CARPPHEUS_PLAYBACK_MODE=auto"
    "CARPPHEUS_MPRIS_PREFERENCE=firefox,firefox-esr,librewolf,zen,vivaldi,opera,chromium,google-chrome,chrome,brave-browser,brave,epiphany,webkit"
    "CARPPHEUS_ARTWORK_CACHE="
    "CARPPHEUS_SEARCH_DEBOUNCE_MS=300"
  ] + "\n";
in
{
  home.packages = [ api ];

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
