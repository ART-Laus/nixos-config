# artlaus/features/desktop/bar/scripts/default.nix
# This file packages the now.sh script for use in the desktop bar.
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "quickshell-now-playing";
  version = "1.0.0";
  
  # The source is this directory, so it can find now.sh
  src = ./.;

  # makeWrapper is needed to add dependencies to the script's PATH
  nativeBuildInputs = [ pkgs.makeWrapper ];

  # The script doesn't need to be built, just installed.
  installPhase = ''
    mkdir -p $out/bin
    # Copy the script into the package's bin directory
    install -m 755 ./now.sh $out/bin/now.sh
    # Wrap the script so it can find its dependencies (curl and jq)
    wrapProgram $out/bin/now.sh --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.curl pkgs.jq ]}
  '';
}
