# lib/theme.nix — чистые функции для темы
{
  # hex → rgba (для Hyprland)
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";

  # hex → rgba с альфа (0.0–1.0 → 00–ff)
  # toRgbaAlpha "#66FF99" 0.85 → "rgba(66FF9985...)" — упрощённо, для Waybar лучше прямо rgba()
  toRgbaAlpha = hex: alpha:
    let
      a = builtins.substring 1 2 hex;
      b = builtins.substring 3 2 hex;
      c = builtins.substring 5 2 hex;
    in "rgba(${a}${b}${c}${builtins.toString (builtins.floor (alpha * 255))})";
}
