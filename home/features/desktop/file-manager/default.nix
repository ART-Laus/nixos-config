# home/features/desktop/file-manager — Thunar как замена Dolphin
# Пакет/сервисы объявляются системным модулем programs.thunar,
# Home Manager отвечает за конфигурацию, тему и custom actions.
{
  imports = [
    ./thunar.nix
    ./actions.nix
  ];
}
