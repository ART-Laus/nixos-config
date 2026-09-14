# theme/colors.nix — ЕДИНСТВЕННЫЙ источник цветов
# Использование: import ./colors.nix  или  specialArgs.theme
# Палитра: Artlaus Neon (Green #66FF99 + Lavender #C4A0FF + AMOLED #001a0d)
{
  # База
  bg = "#001a0d";        # AMOLED тёмный
  bgAlt = "#0D3322";     # панели / полупрозрачный
  fg = "#C0FFC0";        # основной текст (мягкий бело-зелёный)

  # Акценты
  primary = "#66FF99";   # Neon Green — главный
  secondary = "#C4A0FF"; # Lavender — вторичный
  accentBlue = "#58D6FF";# Electric Blue

  # Семантика
  error = "#FF5566";
  warning = "#FFD966";
  success = "#66FF99";   # = primary
  info = "#7FD6FF";

  # Текст
  muted = "#448866";     # вторичный / неактивный
  comment = "#3D6655";   # комментарии
  border = "#448866";    # inactive border
  borderActive = "#66FF99";

  # Выделение
  selection = "rgba(102, 255, 153, 0.3)";
  cursor = "#66FF99";

  # Прозрачность (для Hyprland / Waybar)
  bgTransparent = "rgba(0, 26, 13, 0.85)";
  bgAltTransparent = "rgba(13, 51, 34, 0.7)";
}
