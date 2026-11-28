# actions.nix — Verdant custom actions для Thunar
{ pkgs, lib, ... }:
let
  actionScript = pkgs.writeShellScript "verdant-thunar-actions" ''
    set -eu

    terminal_dir() {
      dir=""
      if [ "$#" -gt 0 ] && [ -d "$1" ]; then
        dir="$1"
        shift
      fi
      while [ "$#" -gt 0 ]; do
        if [ -d "$1" ]; then
          dir="$1"
          break
        fi
        shift
      done
      if [ -z "$dir" ] || [ ! -d "$dir" ]; then
        dir="$PWD"
      fi
      printf '%s' "$dir"
    }

    action="$1"
    shift

    case "$action" in
      terminal)
        dir="$(terminal_dir "$@")"
        exec ${pkgs.alacritty}/bin/alacritty --working-directory "$dir"
        ;;
      yazi)
        dir="$(terminal_dir "$@")"
        exec ${pkgs.alacritty}/bin/alacritty \
          --working-directory "$dir" \
          -e ${pkgs.yazi}/bin/yazi "$dir"
        ;;
      edit)
        [ "$#" -gt 0 ] || exit 0
        exec ${pkgs.alacritty}/bin/alacritty \
          -e ${pkgs.neovim}/bin/nvim -- "$@"
        ;;
      copy-path)
        [ "$#" -gt 0 ] || exit 0
        printf '%s\n' "$1" | ${pkgs.wl-clipboard}/bin/wl-copy
        ;;
      symlink)
        [ "$#" -eq 1 ] || exit 0
        ${pkgs.coreutils}/bin/ln -s -- "$1" "$1 (symlink)"
        ;;
      hardlink)
        [ "$#" -eq 1 ] || exit 0
        ${pkgs.coreutils}/bin/ln -- "$1" "$1 (hardlink)"
        ;;
      *)
        exit 2
        ;;
    esac
  '';

  uca = pkgs.writeText "verdant-thunar-uca.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-terminal-here</unique-id>
        <command>${actionScript} terminal %d %F</command>
        <description>Open Alacritty in the selected folder or current directory</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      <action>
        <icon>system-file-manager</icon>
        <name>Browse with Yazi</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-yazi-here</unique-id>
        <command>${actionScript} yazi %d %F</command>
        <description>Open Yazi in Alacritty at this location</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      <action>
        <icon>text-editor</icon>
        <name>Open in Neovim</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-neovim-edit</unique-id>
        <command>${actionScript} edit %F</command>
        <description>Open selected files in Neovim inside Alacritty</description>
        <range>1-16</range>
        <patterns>*</patterns>
        <startup-notify/>
        <text-files/>
      </action>
      <action>
        <icon>edit-copy</icon>
        <name>Copy Path</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-copy-path</unique-id>
        <command>${actionScript} copy-path %f</command>
        <description>Copy the selected path to the Wayland clipboard</description>
        <range>1-1</range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      <action>
        <icon>emblem-symbolic-link</icon>
        <name>Create Symlink</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-symlink</unique-id>
        <command>${actionScript} symlink %f</command>
        <description>Create a symbolic link next to the selected item</description>
        <range>1-1</range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      <action>
        <icon>emblem-symbolic-link</icon>
        <name>Create Hardlink</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-hardlink</unique-id>
        <command>${actionScript} hardlink %f</command>
        <description>Create a hard link next to the selected file</description>
        <range>1-1</range>
        <patterns>*</patterns>
        <startup-notify/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      <action>
        <icon>system-search</icon>
        <name>Search with Catfish</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-catfish</unique-id>
        <command>${pkgs.catfish}/bin/catfish %f</command>
        <description>Search inside the selected folder</description>
        <range>1-1</range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
      </action>
      <action>
        <icon>application-x-archive</icon>
        <name>Compress with File Roller</name>
        <submenu>Verdant</submenu>
        <unique-id>verdant-compress</unique-id>
        <command>${pkgs.file-roller}/bin/file-roller --add %F --default-dir %d</command>
        <description>Create an archive from the selected files</description>
        <range>1-16</range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
    </actions>
  '';
in
{
  # ua.xml пишется Thunar при редактировании — держим его writable.
  home.activation.verdantThunarActions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/Thunar"
    $DRY_RUN_CMD cp -f ${uca} "$HOME/.config/Thunar/uca.xml"
  '';
}
