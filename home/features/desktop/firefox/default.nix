# home/features/desktop/firefox/default.nix — Firefox с перенесённым Windows-профилем
# Профиль-снимок лежит в ./profile (вычищен по политике ./exclude.txt).
# Тема, расширения (.xpi), юзер-скрипты Tampermonkey, закладки, история, сессии,
# поисковики, cookies, разрешения — всё приезжает с Windows «как есть».
# Пароли (logins.json/key4.db) и FxA-токены намеренно исключены (см. exclude.txt):
# пароли восстанавливаются входом в Firefox Sync, а не файлами.
{ config, pkgs, lib, ... }:

let
  profileDir = ./profile;
  profilePath = "${config.home.homeDirectory}/.mozilla/firefox/artlaus";
  profilesIniPath = "${config.home.homeDirectory}/.mozilla/firefox/profiles.ini";
in
{
  home.packages = [ pkgs.firefox ];

  # При первом запуске раскладываем снимок профиля из Nix-стора в
  # ~/.mozilla/firefox/artlaus и кладём profiles.ini рядом.
  # Далее Firefox свободно пишет в этот каталог — пересборки его не трогают.
  # Новая версия снимка в репо попадёт в профиль только если каталог удалить.
  home.activation.seedFirefoxProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -e "${profilePath}/prefs.js" ]]; then
      mkdir -p "$(dirname "${profilePath}")"
      cp -r "${profileDir}" "${profilePath}"
      chmod -R u+w "${profilePath}"
    fi
    if [[ ! -e "${profilesIniPath}" ]]; then
      mkdir -p "$(dirname "${profilesIniPath}")"
      cp "${./profiles.ini}" "${profilesIniPath}"
    fi
  '';
}