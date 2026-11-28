# theme/default.nix — реэкспорт темы + хелперы
let
  colors = import ./colors.nix;
  fonts = import ./fonts.nix;
in
{
  inherit colors fonts;

  # Verdant GTK3-тема: адресуется из home/gtk-qt.nix как theme.gtk3Verdant
  gtk3Verdant = import ./gtk3-verdant.nix;

  # Хелпер: hex → rgba для Hyprland
  # toRgba "#66FF99" → "rgba(66FF99ff)"
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";
}
