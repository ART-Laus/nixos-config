{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "carpheus-api";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ./carpheus-api $out/bin/carpheus-api
    install -m 755 ./carpheus-mpv-ipc $out/bin/carpheus-mpv-ipc
    wrapProgram $out/bin/carpheus-api \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.curl pkgs.jq pkgs.python3 pkgs.coreutils ]}
    wrapProgram $out/bin/carpheus-mpv-ipc \
      --prefix PATH : ${pkgs.python3}/bin
  '';
}
