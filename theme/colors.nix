# theme/colors.nix — ЕДИНСТВЕННЫЙ источник цветов
# Использование: import ./colors.nix  или  specialArgs.theme
# Палитра: Artlaus Neon (Green #66FF99 + Lavender #C4A0FF + AMOLED #001a0d)
{
  # База
  bg = "#001a0d"; # AMOLED тёмный
  bgAlt = "#0D3322"; # панели / полупрозрачный
  barSection = "#24212c";
  barPill = "#000000"; # фон таблеток панели
  barPillOpacity = 0.7;
  barPillHoverOpacity = 0.85;
  barPillActiveOpacity = 0.2;
  barTooltipOpacity = 0.9;
  fg = "#C0FFC0"; # основной текст (мягкий бело-зелёный)

  # Акценты
  primary = "#66FF99"; # Neon Green — главный
  primaryDim = "#42A663"; # тот же оттенок, затемнённый для фона панели
  secondary = "#C4A0FF"; # Lavender — вторичный
  accentBlue = "#58D6FF"; # Electric Blue
  emerald = "#10b981"; # Emerald — акцент
  emeraldBright = "#34d399"; # Светлый изумруд
  emeraldTransparent = "rgba(16, 185, 129, 0.45)"; # Полупрозрачный фон панели
  emeraldTransparentLow = "rgba(16, 185, 129, 0.2)"; # Фон блоков панели
  cyan = "#88ddff"; # Cyan — функции, методы
  pink = "#FF66CC"; # Pink — строки
  turquoise = "#009999"; # Turquoise — визуальное выделение
  blue = "#3399FF"; # Blue — числа, булевы

  # Семантика
  error = "#FF5566";
  warning = "#FFD966";
  success = "#66FF99"; # = primary
  info = "#7FD6FF";
  diffAdd = "#00FF88"; # Diff add

  # Текст
  muted = "#448866"; # вторичный / неактивный
  comment = "#3D6655"; # комментарии
  border = "#448866"; # inactive border
  borderActive = "#66FF99";
  lineNr = "#2FAA77"; # номера строк Neovim

  # Выделение
  selection = "rgba(102, 255, 153, 0.3)";
  cursor = "#66FF99";

  # Нейтральные
  nearBlack = "#0A0A0F"; # почти чёрный (текст курсора)
  darkGray = "#1E1E2E"; # тёмный серый (терминал black)
  darkGrayBright = "#2E2E3E"; # светлый тёмный серый (терминал bright black)
  gray = "#666666"; # серый (inactive)
  lightPink = "#FFBBDD"; # светлый pink
  lightBlue = "#B0E8FF"; # светлый blue
  lightLavender = "#D4B8FF"; # светлый lavender
  lightGreen = "#99FFBB"; # Starship username
  mint = "#66DDCC"; # Starship directory
  brightGreen = "#55EE88"; # Starship git
  seaGreen = "#55BBAA"; # Starship cmd_duration/time

  # Прозрачность (для Hyprland / панели)
  shadow = "rgba(00000066)";
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

  # Verdant / Living Terminal — канонические токены для Qt/KDE, GTK и Quickshell.
  # Единый источник: home/gtk-qt.nix и theme/gtk3-verdant.nix потребивают отсюда.
  verdant = {
    deep = "#07110D";       # внешний canvas, тени текста
    forest = "#001a0d";     # Deep Forest — фон встроенного терминала
    main = "#0C1B14";       # основная поверхность / view
    elevated = "#12251B";   # панели, заголовки, кнопки
    hover = "#193325";      # hover-поверхность
    border = "#1D3A2A";     # тонкие границы и разделители
    selection = "#224334";  # мягкая заливка выделения
    text = "#E2F5E9";
    text2 = "#A0B9A9";
    muted = "#728F7E";      # скорректировано с #698675 для контраста 5.0:1
    mint = "#66FF99";       # только фокус/активные состояния
    emerald = "#36C98B";    # выделение и success
    sage = "#A5E6B8";       # папки и places
    lavender = "#C4A0FF";   # вторичный акцент, visited
    warning = "#F2C15B";
    danger = "#FF7A90";
  };
}
