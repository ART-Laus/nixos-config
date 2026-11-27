{ lib
, stdenv
, fetchurl
, makeBinaryWrapper
, ripgrep
, wayland
}:

stdenv.mkDerivation rec {
  pname = "opencode";
  version = "2.4.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-2.4.1.tgz";
    hash = "sha512-FYQAnneVlLmqy862674vvRVkj8yHuZAFHJGV3UCGQxo8aKG58IHPKrspbxruVajnIEpb0t8PeO63H/oW4vJG5A==";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  sourceRoot = "package";

  dontStrip = true;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    wrapProgram $out/bin/opencode \
      --set OPENCODE_DISABLE_AUTOUPDATE true \
      --suffix PATH : ${lib.makeBinPath [ ripgrep ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc wayland ]}
    runHook postInstall
  '';

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
}
