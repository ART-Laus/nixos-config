# home/features/desktop/dolphin.nix — визуальные настройки Dolphin.
# Важно: Dolphin пишет в dolphinrc runtime-состояние (ViewPropsTimestamp),
# поэтому файл должен оставаться writable. Декларативный шаблон копируется
# на каждый switch, а не монтируется symlink'ом на store.
{ pkgs, lib, ... }:
let
  dolphinrc = pkgs.writeText "dolphinrc-verdant" ''
    [General]
    Version=202
    EditableUrl=false
    ShowFullPath=false
    ShowZoomSlider=false
    AlwaysShowTabBar=false
    ShowCloseButtonOnTabs=true

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22

    [MainWindow]
    MenuBar=Disabled

    [DetailsMode]
    HighlightEntireRow=false
  '';
in
{
  home.activation.verdantDolphinConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config"
    $DRY_RUN_CMD cp -f ${dolphinrc} "$HOME/.config/dolphinrc"
  '';
}
