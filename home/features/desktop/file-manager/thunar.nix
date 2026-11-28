# thunar.nix — декларативные настройки Thunar через Xfconf + XDG
{ pkgs, lib, ... }:
let
  # Xfconf перезаписывает свой XML при изменении настроек, поэтому файл должен
  # оставаться writable: копируем шаблон на каждый switch, а не symlink в store.
  xfconfThunar = pkgs.writeText "thunar-xfconf.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="thunar" version="1.0">
      <property name="/default-view" type="string" value="void"/>
      <property name="/last-view" type="string" value="ThunarIconView"/>
      <property name="/last-location-bar" type="string" value="ThunarLocationButtons"/>
      <property name="/last-show-hidden" type="bool" value="false"/>
      <property name="/last-icon-view-zoom-level" type="int" value="4"/>
      <property name="/last-details-view-zoom-level" type="int" value="1"/>
      <property name="/last-compact-view-zoom-level" type="int" value="0"/>
      <property name="/last-side-pane" type="int" value="0"/>
      <property name="/last-sort-column" type="int" value="8"/>
      <property name="/last-sort-order" type="int" value="0"/>
      <property name="/last-statusbar-visible" type="bool" value="true"/>
      <property name="/last-image-preview-visible" type="bool" value="false"/>
      <property name="/last-menubar-visible" type="bool" value="false"/>
      <property name="/last-window-width" type="int" value="1280"/>
      <property name="/last-window-height" type="int" value="800"/>
      <property name="/last-window-maximized" type="bool" value="false"/>
      <property name="/last-restore-tabs" type="bool" value="false"/>
      <property name="/misc-always-show-tabs" type="bool" value="false"/>
      <property name="/misc-open-new-window-as-tab" type="bool" value="false"/>
      <property name="/misc-middle-click-in-tab" type="bool" value="true"/>
      <property name="/misc-tab-close-middle-click" type="bool" value="true"/>
      <property name="/misc-folder-item-count" type="int" value="0"/>
      <property name="/misc-folders-first" type="bool" value="true"/>
      <property name="/misc-hidden-last" type="bool" value="true"/>
      <property name="/misc-highlighting-enabled" type="bool" value="true"/>
      <property name="/misc-thumbnail-mode" type="int" value="1"/>
      <property name="/misc-thumbnail-draw-frames" type="bool" value="false"/>
      <property name="/misc-image-preview-mode" type="int" value="1"/>
      <property name="/misc-show-delete-action" type="bool" value="true"/>
      <property name="/misc-confirm-move-to-trash" type="bool" value="true"/>
      <property name="/misc-directory-specific-settings" type="bool" value="false"/>
      <property name="/misc-recursive-search" type="int" value="1"/>
      <property name="/misc-recursive-permissions" type="int" value="0"/>
      <property name="/misc-volume-management" type="bool" value="false"/>
      <property name="/misc-exec-shell-scripts-by-default" type="int" value="2"/>
      <property name="/misc-remember-geometry" type="bool" value="true"/>
      <property name="/misc-use-csd" type="bool" value="true"/>
      <property name="/misc-symbolic-icons-in-toolbar" type="bool" value="false"/>
      <property name="/misc-symbolic-icons-in-sidepane" type="bool" value="false"/>
      <property name="/misc-small-toolbar-icons" type="bool" value="false"/>
      <property name="/misc-text-beside-icons" type="bool" value="true"/>
      <property name="/misc-expandable-folders" type="bool" value="true"/>
      <property name="/misc-tree-lines-in-tree-sidepane" type="bool" value="false"/>
      <property name="/misc-change-window-icon" type="bool" value="false"/>
      <property name="/misc-undo-redo-history-size" type="int" value="20"/>
      <property name="/shortcuts-icon-emblems" type="bool" value="false"/>
      <property name="/tree-icon-emblems" type="bool" value="false"/>
    </channel>
  '';
in
{
  # Каталоги открываются в Thunar везде: xdg-open, файл-пикеры, Quickshell.
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "x-directory/normal" = "thunar.desktop";
  };

  # Xfce helpers: terminal из настроек системы, а не exo-open по умолчанию.
  xdg.configFile."xfce4/helpers.rc".text = ''
    FileManager=thunar
    TerminalEmulator=alacritty
    WebBrowser=firefox
  '';

  # Специальные папки получают иконки из Papirus-Green places/*.
  xdg.configFile."user-dirs.dirs".text = ''
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="$HOME/Documents"
    XDG_MUSIC_DIR="$HOME/Music"
    XDG_PICTURES_DIR="$HOME/Pictures"
    XDG_VIDEOS_DIR="$HOME/Videos"
  '';

  # Papirus-Green содержит иконки places/*, но сами каталоги должны существовать,
  # чтобы sidebar и file chooser показывали их с правильными иконками.
  home.activation.verdantUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for dir in Desktop Templates Public Pictures; do
      $DRY_RUN_CMD mkdir -p "$HOME/$dir"
    done
  '';

  home.activation.verdantThunarConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    $DRY_RUN_CMD cp -f ${xfconfThunar} "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
  '';

  # Удаляем только однозначно Dolphin/KIO-специфичное состояние.
  home.activation.verdantRemoveDolphinState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -f "$HOME/.config/dolphinrc"
    $DRY_RUN_CMD rm -rf "$HOME/.local/share/dolphin"
    $DRY_RUN_CMD rm -rf "$HOME/.config/session/dolphin_dolphin_dolphin"
    $DRY_RUN_CMD rm -f "$HOME/.config/kiorc"
    $DRY_RUN_CMD rm -f "$HOME/.config/baloofileinformationrc"
    $DRY_RUN_CMD rm -rf "$HOME/.local/share/baloo"
  '';
}
