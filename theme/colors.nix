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
  cyan = "#88ddff";      # Cyan — функции, методы
  pink = "#FF66CC";      # Pink — строки
  turquoise = "#009999"; # Turquoise — визуальное выделение
  blue = "#3399FF";      # Blue — числа, булевы

  # Семантика
  error = "#FF5566";
  warning = "#FFD966";
  success = "#66FF99";   # = primary
  info = "#7FD6FF";
  diffAdd = "#00FF88";   # Diff add

  # Текст
  muted = "#448866";     # вторичный / неактивный
  comment = "#3D6655";   # комментарии
  border = "#448866";    # inactive border
  borderActive = "#66FF99";
  lineNr = "#2FAA77";    # номера строк Neovim

  # Выделение
  selection = "rgba(102, 255, 153, 0.3)";
  cursor = "#66FF99";

  # Нейтральные
  nearBlack = "#0A0A0F"; # почти чёрный (текст курсора)
  darkGray = "#1E1E2E";  # тёмный серый (терминал black)
  darkGrayBright = "#2E2E3E"; # светлый тёмный серый (терминал bright black)
  gray = "#666666";      # серый (inactive)
lightPink = "#FFBBDD"; # светлый pink
    lightBlue = "#B0E8FF"; # светлый blue
    lightLavender = "#D4B8FF"; # светлый lavender
    lightGreen = "#99FFBB"; # Starship username
    mint = "#66DDCC"; # Starship directory
    brightGreen = "#55EE88"; # Starship git
    seaGreen = "#55BBAA"; # Starship cmd_duration/time

  # Прозрачность (для Hyprland / Waybar)
  shadow = "rgba(0, 0, 0, 0.4)";
  bgTransparent = "rgba(0, 26, 13, 0.85)";
  bgAltTransparent = "rgba(13, 51, 34, 0.7)";
  secondaryTransparent = "rgba(196, 160, 255, 0.3)";
  secondaryTransparentLow = "rgba(196, 160, 255, 0.1)";
  fgTransparent = "rgba(192, 255, 192, 0.7)";
  fgTransparentLow = "rgba(192, 255, 192, 0.2)";
  warningTransparent = "rgba(255, 213, 0, 0.6)";
  warningTransparentHigh = "rgba(255, 213, 0, 0.7)";
  accentBlueTransparent = "rgba(88, 214, 255, 0.6)";
  errorTransparent = "rgba(255, 85, 102, 0.6)";
  errorTransparentHigh = "rgba(255, 85, 102, 0.8)";
  successTransparent = "rgba(102, 255, 153, 0.6)";
  successTransparentHigh = "rgba(102, 255, 153, 0.7)";
}
