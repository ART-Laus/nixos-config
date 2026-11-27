{ pkgs, lib, ... }:
let
  python = pkgs.python3.withPackages (p: [ p.dbus-fast p.jeepney ]);
in
pkgs.stdenv.mkDerivation {
  pname = "orpheus-daemon";
  version = "0.2.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper python ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m755 orpheus-daemon "$out/bin/orpheus-daemon"
    install -m755 orpheus-ipc "$out/bin/orpheus-ipc"
    wrapProgram "$out/bin/orpheus-daemon" \
      --prefix PATH : ${lib.makeBinPath [ python pkgs.mpv pkgs.imagemagick ]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Orpheus headless music coordinator";
    platforms = platforms.linux;
  };
}
