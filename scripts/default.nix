# scripts/default.nix
# This file defines a Nix package for our custom media scripts.
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "rofi-media-scripts";
  version = "1.0.0";

  # The source for this package is the directory it's in.
  src = ./.;

  # We need makeWrapper to wrap the scripts with their dependencies.
  nativeBuildInputs = [ pkgs.makeWrapper ];

  # The install phase is where we build the package.
  installPhase = ''
    # Create the bin directory in the output path
    mkdir -p $out/bin

    # Copy the scripts, make them executable, and remove the .sh extension
    install -m 755 ./rofi-scripts.sh $out/bin/rofi-scripts
    install -m 755 ./media/rofi-image.sh $out/bin/rofi-image
    install -m 755 ./media/rofi-video.sh $out/bin/rofi-video
    install -m 755 ./media/rofi-audio.sh $out/bin/rofi-audio

    # The scripts need access to tools like ffmpeg, rofi, etc. to run.
    # We use makeWrapper to add these tools to each script's PATH, so they
    # are always available when the script is run. This is the idiomatic Nix way.
    
    # The main launcher only needs rofi itself.
    wrapProgram $out/bin/rofi-scripts --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rofi ]}
    
    # The image script needs rofi, imagemagick, libnotify, and fd.
    wrapProgram $out/bin/rofi-image --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rofi pkgs.imagemagick-full pkgs.libnotify pkgs.fd ]}
    
    # The video script needs rofi, ffmpeg, libnotify, and fd.
    wrapProgram $out/bin/rofi-video --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rofi pkgs.ffmpeg pkgs.libnotify pkgs.fd ]}
    
    # The audio script also needs rofi, ffmpeg, libnotify, and fd.
    wrapProgram $out/bin/rofi-audio --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.rofi pkgs.ffmpeg pkgs.libnotify pkgs.fd ]}
  '';
}
