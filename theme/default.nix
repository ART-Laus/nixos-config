# theme/default.nix — реэкспорт темы + хелперы
let
  colors = import ./colors.nix;
  fonts = import ./fonts.nix;
in
{
  inherit colors fonts;

  # Хелпер: hex → rgba для Hyprland
  # toRgba "#66FF99" → "rgba(66FF99ff)"
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";

  # Пример: mkWaybarCss colors → CSS-строка (используется в home/desktop.nix)
  # mkWaybarCss = colors: ''window#waybar { background: ${colors.bg}; }'';
}
