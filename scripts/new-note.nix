# nixos-config/scripts/new-note.nix
{ pkgs }:

pkgs.writeShellScriptBin "new-note" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  # Check if a note title is provided
  if [ -z "$1" ]; then
    echo "Please provide a title for your note."
    exit 1
  fi

  # Define the notes directory and the ideas sub-directory
  NOTES_DIR="/mnt/c/Users/user/Documents/ALN"
  IDEAS_DIR="$NOTES_DIR/00 - Ideas"

  # Create the directories if they don't exist
  ${pkgs.coreutils}/bin/mkdir -p "$IDEAS_DIR"

  # Create the full path for the new note
  NOTE_PATH="$IDEAS_DIR/$1.md"

  # Create the file and open it in Neovim
  # We use exec to replace the shell process with nvim
  exec ${pkgs.neovim}/bin/nvim "$NOTE_PATH"
''
