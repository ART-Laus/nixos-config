# Backend package for Verdant Clipboard.
# Pure Nix wrapper around the stdlib-only Python daemon: no cargo toolchain,
# no vendored crates, no runtime downloads.
{ pkgs }:
let
  source = ./backend/verdant_clipboard.py;
  python = pkgs.python3;

  daemon = pkgs.writeShellScriptBin "verdant-clipboard" ''
    exec ${python.interpreter} ${source} daemon "$@"
  '';

  ctl = pkgs.writeShellScriptBin "verdant-clipboard-ctl" ''
    exec ${python.interpreter} ${source} ctl "$@"
  '';
in
pkgs.symlinkJoin {
  name = "verdant-clipboard";
  paths = [ daemon ctl ];
}
