# QML source package. It is copied into the single existing `bar` Quickshell
# config in bar/quickshell.nix, so no second Quickshell instance is created.
{ pkgs }:
pkgs.runCommand "verdant-clipboard-shell" { } ''
  mkdir -p "$out"
  cp -r ${./shell}/. "$out/"
  chmod -R u+w "$out"
''
