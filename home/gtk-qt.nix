# home/gtk-qt.nix — GTK + Qt тема из theme/ (единый стиль)
# Qt/KDE: чёрная полупрозрачная оболочка, зелёные (#66FF99) элементы и папки
{ config, pkgs, lib, theme, ... }:
let
  c = theme.colors;
  black = rgb "#000000";

  digit = ch: builtins.getAttr (lib.toLower ch) {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };
  rgb = hex:
    let h = lib.toLower hex;
    in "${toString (digit (builtins.substring 1 1 h) * 16 + digit (builtins.substring 2 1 h))},"
      + "${toString (digit (builtins.substring 3 1 h) * 16 + digit (builtins.substring 4 1 h))},"
      + "${toString (digit (builtins.substring 5 1 h) * 16 + digit (builtins.substring 6 1 h))}";

  # Иконки папок Papirus, перекрашенные в системный зелёный
  greenIcons = pkgs.runCommand "papirus-green-folders" { } ''
    src="${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark"
    dest="$out/share/icons/Papirus-Green"
    mkdir -p "$dest"

    for dir in "$src"/*/places; do
      size=$(basename "$(dirname "$dir")")
      mkdir -p "$dest/$size/places"
      for f in "$dir"/*.svg; do
        [ -e "$f" ] || continue
        sed \
          -e 's/#5294e2/#66ff99/g' -e 's/#4285f4/#66ff99/g' \
          -e 's/#4caf50/#66ff99/g' -e 's/#f44336/#66ff99/g' \
          -e 's/#ff9800/#66ff99/g' -e 's/#93c0ea/#66ff99/g' \
          -e 's/#87b158/#66ff99/g' -e 's/#81a1c1/#66ff99/g' \
          -e 's/#7e57c2/#66ff99/g' -e 's/#5c6bc0/#66ff99/g' \
          -e 's/#57b8ec/#66ff99/g' -e 's/#16a085/#66ff99/g' \
          -e 's/#45abb7/#66ff99/g' -e 's/#4877b1/#42a663/g' \
          -e 's/#1d344f/#0d3322/g' -e 's/#f9bd30/#42a663/g' \
          -e 's/#f06292/#42a663/g' -e 's/#eeca8f/#42a663/g' \
          -e 's/#ee923a/#42a663/g' -e 's/#eb6637/#42a663/g' \
          -e 's/#e25252/#42a663/g' -e 's/#d1bfae/#42a663/g' \
          -e 's/#ca71df/#42a663/g' -e 's/#ae8e6c/#42a663/g' \
          -e 's/#a30002/#42a663/g' -e 's/#8e8e8e/#42a663/g' \
          -e 's/#607d8b/#42a663/g' \
          "$f" > "$dest/$size/places/$(basename "$f")"
      done
    done

    {
      printf '[Icon Theme]\n'
      printf 'Name=Papirus-Green\n'
      printf 'Comment=Papirus folders in Artlaus green\n'
      printf 'Inherits=Papirus-Dark,breeze-dark,hicolor\n'
      printf 'Example=folder\n'
      printf 'FollowsColorScheme=true\n'
      printf 'Directories='
      first=1
      for dir in "$src"/*/places; do
        size=$(basename "$(dirname "$dir")")
        if [ "$first" -eq 0 ]; then printf ','; fi
        printf '%s/places' "$size"
        first=0
      done
      printf '\n\n'
      for dir in "$src"/*/places; do
        size=$(basename "$(dirname "$dir")")
        base=$(printf '%s' "$size" | cut -d x -f 1)
        printf '[%s/places]\nSize=%s\nContext=Places\n\n' "$size" "$base"
      done
    } > "$dest/index.theme"
  '';

  # SVG-элементы Kvantum: серые заливки → чёрный, светлые → зелёный
  greenSvg = pkgs.runCommand "artlaus-neon-kvantum-svg" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - <<'PY' > "$out"
    import re
    src = "${pkgs.qt6Packages.qtstyleplugin-kvantum}/share/Kvantum/KvDark/KvDark.svg"
    def repl(m):
        h = m.group(1)
        if len(h) == 3:
            h = "".join(ch * 2 for ch in h)
        r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
        if max(r, g, b) - min(r, g, b) <= 12:
            v = (r + g + b) // 3
            return "#000000" if v < 100 else ("#0a0a0a" if v < 180 else "#66ff99")
        return m.group(0)
    print(re.sub(r'#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b', repl, open(src).read()), end="")
    PY
  '';

  # Kvantum: чёрный фон, зелёный текст/акценты, прозрачный вид Dolphin
  kvDark = builtins.readFile "${pkgs.qt6Packages.qtstyleplugin-kvantum}/share/Kvantum/KvDark/KvDark.kvconfig";
  kvantumTheme = builtins.replaceStrings
    [
      "#3D3D3E"
      "#2E2E2E"
      "#383838"
      "#646464"
      "#555555"
      "#1e1e1e"
      "#3C3C3C"
      "#c3c3c3"
      "#b9b9b9"
      "#A0A0A0"
      "#2EB8E6"
      "#FF6666"
      "white"
      "black"
      "transparent_dolphin_view=false"
      "translucent_windows=false"
      "blurring=false"
      "transparent_menutitle=false"
    ]
    [
      "#000000"
      "#000000"
      "#0a0a0a"
      "#1a1a1a"
      "#111111"
      "#000000"
      "#0a0a0a"
      c.primary
      c.primaryDim
      c.primary
      c.primary
      "#99ffbb"
      c.primary
      "#000000"
      "transparent_dolphin_view=true"
      "translucent_windows=true"
      "blurring=true"
      "transparent_menutitle=true"
    ]
    kvDark;

  # Палитра KDE/Qt6: оболочка чёрная, текст/иконки/выделение зелёные
  kdeColors = ''
    [ColorEffects:Disabled]
    Color=${rgb c.muted}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=0

    [ColorEffects:Inactive]
    ChangeSelectionColor=false
    Color=${rgb c.muted}
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=true
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=${rgb "#0a0a0a"}
    BackgroundNormal=${black}
    DecorationFocus=${rgb c.primary}
    DecorationHover=${rgb c.primary}
    ForegroundActive=${rgb c.primary}
    ForegroundInactive=${rgb c.primary}
    ForegroundLink=${rgb c.primary}
    ForegroundNegative=${rgb c.error}
    ForegroundNeutral=${rgb c.warning}
    ForegroundNormal=${rgb c.primary}
    ForegroundPositive=${rgb c.success}
    ForegroundVisited=${rgb "#99ffbb"}

    [Colors:Selection]
    BackgroundAlternate=${rgb c.primaryDim}
    BackgroundNormal=${rgb c.primary}
    DecorationFocus=${rgb c.primary}
    DecorationHover=${rgb c.primary}
    ForegroundActive=${black}
    ForegroundInactive=${rgb c.primary}
    ForegroundLink=${rgb c.primary}
    ForegroundNegative=${rgb c.error}
    ForegroundNeutral=${rgb c.warning}
    ForegroundNormal=${black}
    ForegroundPositive=${rgb c.success}
    ForegroundVisited=${rgb "#99ffbb"}

    [Colors:Tooltip]
    BackgroundAlternate=${black}
    BackgroundNormal=${black}
    DecorationFocus=${rgb c.primary}
    DecorationHover=${rgb c.primary}
    ForegroundActive=${rgb c.primary}
    ForegroundInactive=${rgb c.primary}
    ForegroundLink=${rgb c.primary}
    ForegroundNegative=${rgb c.error}
    ForegroundNeutral=${rgb c.warning}
    ForegroundNormal=${rgb c.primary}
    ForegroundPositive=${rgb c.success}
    ForegroundVisited=${rgb "#99ffbb"}

    [Colors:View]
    BackgroundAlternate=${rgb "#0a0a0a"}
    BackgroundNormal=${black}
    DecorationFocus=${rgb c.primary}
    DecorationHover=${rgb c.primary}
    ForegroundActive=${rgb c.primary}
    ForegroundInactive=${rgb c.primary}
    ForegroundLink=${rgb c.primary}
    ForegroundNegative=${rgb c.error}
    ForegroundNeutral=${rgb c.warning}
    ForegroundNormal=${rgb c.primary}
    ForegroundPositive=${rgb c.success}
    ForegroundVisited=${rgb "#99ffbb"}

    [Colors:Window]
    BackgroundAlternate=${rgb "#0a0a0a"}
    BackgroundNormal=${black}
    DecorationFocus=${rgb c.primary}
    DecorationHover=${rgb c.primary}
    ForegroundActive=${rgb c.primary}
    ForegroundInactive=${rgb c.primary}
    ForegroundLink=${rgb c.primary}
    ForegroundNegative=${rgb c.error}
    ForegroundNeutral=${rgb c.warning}
    ForegroundNormal=${rgb c.primary}
    ForegroundPositive=${rgb c.success}
    ForegroundVisited=${rgb "#99ffbb"}

    [General]
    ColorScheme=ArtlausNeon
    Name=Artlaus Neon
    shadeSortColumn=true

    [KDE]
    contrast=0

    [WM]
    activeBackground=${black}
    activeBlend=${black}
    activeForeground=${rgb c.primary}
    inactiveBackground=${black}
    inactiveBlend=${black}
    inactiveForeground=${rgb c.primary}
  '';

  #qt6ct: принудительная палитра Qt — Dolphin рисует текст через QPalette
  palText = "#ff66ff99";
  palBg = "#ff000000";
  palAlt = "#ff0a0a0a";
  palLight = "#ff1a1a1a";
  palMid = "#ff111111";
  palBright = "#ff99ffbb";
  palDim = "#ff42a663";
  activePalette = [
    palText
    palBg
    palLight
    palMid
    palBg
    palAlt
    palText
    palBright
    palText
    palBg
    palBg
    palBg
    palText
    palBg
    palText
    palBright
    palAlt
    palBg
    palText
    palBg
    palDim
  ];
  qt6ctPalette = ''
    [ColorScheme]
    active_colors=${lib.concatStringsSep ", " activePalette}
    disabled_colors=${lib.concatStringsSep ", " activePalette}
    inactive_colors=${lib.concatStringsSep ", " activePalette}
  '';
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Green";
      package = greenIcons;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "${theme.fonts.ui.name} ${toString theme.fonts.ui.size}";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      settings.General.theme = "ArtlausNeon";
    };
    qt6ctSettings.Appearance = {
      style = "Kvantum";
      icon_theme = "Papirus-Green";
      custom_palette = true;
      color_scheme_path = "~/.config/qt6ct/colors/ArtlausNeon.conf";
    };
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
  ];

  # Чёрная зелёная тема Kvantum с прозрачным видом Dolphin
  xdg.configFile."Kvantum/ArtlausNeon/ArtlausNeon.kvconfig".text = kvantumTheme;
  xdg.configFile."Kvantum/ArtlausNeon/ArtlausNeon.svg".source = greenSvg;
  xdg.configFile."qt6ct/colors/ArtlausNeon.conf".text = qt6ctPalette;

  # Палитра KDE/Qt6 для Dolphin и других KDE-приложений
  xdg.dataFile."color-schemes/ArtlausNeon.colors".text = kdeColors;
  xdg.dataFile."color-schemes/BreezeLight.colors".text = kdeColors;
  xdg.dataFile."color-schemes/BreezeDark.colors".text = kdeColors;
  xdg.configFile."kdeglobals".text = ''
    ${kdeColors}

    [Icons]
    Theme=Papirus-Green
  '';

  # Stylix — пока не используется (модуль не подключён), GTK/Qt делаем вручную
}

