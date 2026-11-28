# home/gtk-qt.nix — GTK + Qt тема из theme/ (единый стиль)
# Qt/KDE: Verdant / Living Terminal — токены из theme.colors.verdant
{ config, pkgs, lib, theme, ... }:
let
  # Единый источник токенов — theme/colors.nix (theme.verdant).
  lt = theme.colors.verdant;

  verdantGtk = theme.gtk3Verdant {
    inherit pkgs;
    colors = lt;
    fonts = theme.fonts;
  };

  # Палитра Qt/KDE: плотные слои Verdant, зелёный — только акцент.
  v = {
    canvas = lt.main;      # фон окна и view
    main = lt.main;        # base
    elev = lt.elevated;    # панели, кнопки, альтернативные строки
    hover = lt.hover;      # surface под курсором
    line = lt.border;      # границы и разделители
    selection = lt.selection; # мягкая заливка выделения
    text = lt.text;        # основной текст
    text2 = lt.text2;      # вторичный текст
    muted = lt.muted;      # disabled/placeholder
    mint = lt.mint;        # только фокус/акцент
    emerald = lt.emerald;  # семантика «хорошо»
    sage = lt.sage;        # папки/иконки places
    lavender = lt.lavender;
    danger = lt.danger;
    warning = lt.warning;
  };

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
  argb = hex: "#ff${builtins.substring 1 6 hex}";

  # Papirus: только places/*, папки в sage (#A5E6B8), устройства в emerald (#36C98B)
  greenIcons = pkgs.runCommand "papirus-verdant-places" { } ''
    src="${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark"
    dest="$out/share/icons/Papirus-Green"
    mkdir -p "$dest"

    for dir in "$src"/*/places; do
      size=$(basename "$(dirname "$dir")")
      mkdir -p "$dest/$size/places"
      for f in "$dir"/*.svg; do
        [ -e "$f" ] || continue
        sed \
          -e 's/#5294e2/${lt.sage}/g' -e 's/#4285f4/${lt.sage}/g' \
          -e 's/#4caf50/${lt.sage}/g' -e 's/#f44336/${lt.sage}/g' \
          -e 's/#ff9800/${lt.sage}/g' -e 's/#93c0ea/${lt.sage}/g' \
          -e 's/#87b158/${lt.sage}/g' -e 's/#81a1c1/${lt.sage}/g' \
          -e 's/#7e57c2/${lt.sage}/g' -e 's/#5c6bc0/${lt.sage}/g' \
          -e 's/#57b8ec/${lt.sage}/g' -e 's/#16a085/${lt.sage}/g' \
          -e 's/#45abb7/${lt.sage}/g' -e 's/#4877b1/${lt.emerald}/g' \
          -e 's/#1d344f/${lt.elevated}/g' -e 's/#f9bd30/${lt.emerald}/g' \
          -e 's/#f06292/${lt.emerald}/g' -e 's/#eeca8f/${lt.emerald}/g' \
          -e 's/#ee923a/${lt.emerald}/g' -e 's/#eb6637/${lt.emerald}/g' \
          -e 's/#e25252/${lt.emerald}/g' -e 's/#d1bfae/${lt.emerald}/g' \
          -e 's/#ca71df/${lt.emerald}/g' -e 's/#ae8e6c/${lt.emerald}/g' \
          -e 's/#a30002/${lt.emerald}/g' -e 's/#8e8e8e/${lt.emerald}/g' \
          -e 's/#607d8b/${lt.emerald}/g' \
          "$f" > "$dest/$size/places/$(basename "$f")"
      done
    done

    {
      printf '[Icon Theme]\n'
      printf 'Name=Papirus-Green\n'
      printf 'Comment=Papirus places in Artlaus green\n'
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

  # SVG Kvantum: серые градации → слои Verdant / Living Terminal
  greenSvg = pkgs.runCommand "verdant-kvantum-svg" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    python3 - <<'PY' > "$out"
    import re
    src = "${pkgs.qt6Packages.qtstyleplugin-kvantum}/share/Kvantum/KvDark/KvDark.svg"
    bg, alt, edge, text = "${lt.deep}", "${lt.elevated}", "${lt.border}", "${lt.text}"
    def repl(m):
        h = m.group(1)
        if len(h) == 3:
            h = "".join(ch * 2 for ch in h)
        r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
        if max(r, g, b) - min(r, g, b) <= 12:
            tone = (r + g + b) // 3
            if tone < 100: return bg
            if tone < 180: return alt
            if tone < 220: return edge
            return text
        return m.group(0)
    print(re.sub(r'#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b', repl, open(src).read()), end="")
    PY
  '';

  kvDark = builtins.readFile "${pkgs.qt6Packages.qtstyleplugin-kvantum}/share/Kvantum/KvDark/KvDark.kvconfig";

  # GeneralColors целиком — window/view/button получают разные слои
  kvColorsFrom = "window.color=#3D3D3E\n"
    + "base.color=#2E2E2E\n"
    + "alt.base.color=#383838\n"
    + "button.color=#3D3D3E\n"
    + "light.color=#646464\n"
    + "mid.light.color=#555555\n"
    + "dark.color=#1e1e1e\n"
    + "mid.color=#3C3C3C\n"
    + "highlight.color=#c3c3c3\n"
    + "inactive.highlight.color=#b9b9b9\n"
    + "text.color=white\n"
    + "window.text.color=white\n"
    + "button.text.color=white\n"
    + "disabled.text.color=#A0A0A0\n"
    + "tooltip.text.color=white\n"
    + "highlight.text.color=black\n"
    + "link.color=#2EB8E6\n"
    + "link.visited.color=#FF6666\n"
    + "progress.indicator.text.color=black";
  kvColorsTo = "window.color=${v.canvas}\n"
    + "base.color=${v.main}\n"
    + "alt.base.color=${v.elev}\n"
    + "button.color=${v.elev}\n"
    + "light.color=${v.hover}\n"
    + "mid.light.color=${v.line}\n"
    + "dark.color=${lt.deep}\n"
    + "mid.color=${v.elev}\n"
    + "highlight.color=${v.selection}\n"
    + "inactive.highlight.color=${v.line}\n"
    + "text.color=${v.text}\n"
    + "window.text.color=${v.text}\n"
    + "button.text.color=${v.text}\n"
    + "disabled.text.color=${v.muted}\n"
    + "tooltip.text.color=${v.text}\n"
    + "highlight.text.color=${v.text}\n"
    + "link.color=${v.mint}\n"
    + "link.visited.color=${v.lavender}\n"
    + "progress.indicator.text.color=${v.canvas}";

  # translucency/blur сохранены; respect_darkness отключён,
  # иначе активные Qt-окна красят текст в серый.
  # Радиусы: frame.expansion 10 (radiusControl) и 14 (radiusCard/панели),
  # тени текста — в deep surface вместо чёрного.
  kvantumTheme = builtins.replaceStrings
    [
      kvColorsFrom
      "menu_shadow_depth=7"
      "tooltip_shadow_depth=6"
      "layout_spacing=3\n"
      "respect_darkness=true"
      "transparent_menutitle=false"
      "translucent_windows=false\nblurring=false"
      "text.shadow.color=#000000"
      "frame.expansion=8"
      "[GenericFrame]\ninherits=PanelButtonCommand\nframe.element=group\n"
      "white"
      "black"
    ]
    [
      kvColorsTo
      "menu_shadow_depth=3"
      "tooltip_shadow_depth=3"
      "layout_spacing=8\nlayout_margin=10\n"
      "respect_darkness=false"
      "transparent_menutitle=true"
      "translucent_windows=true\nblurring=true"
      "text.shadow.color=${lt.deep}"
      "frame.expansion=14"
      "[GenericFrame]\ninherits=PanelButtonCommand\nframe.element=group\nframe.expansion=14\n"
      v.text
      v.text
    ]
    kvDark;

  # KDE/Qt6 color scheme: фон терминала + текстовые/семантические токены Living Terminal
  kdeColors = ''
    [ColorEffects:Disabled]
    Color=${rgb v.canvas}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0
    ContrastEffect=0
    IntensityAmount=0
    IntensityEffect=0

    [ColorEffects:Inactive]
    ChangeSelectionColor=false
    Color=${rgb v.canvas}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0
    ContrastEffect=0
    Enable=true
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=${rgb v.hover}
    BackgroundNormal=${rgb v.elev}
    DecorationFocus=${rgb v.mint}
    DecorationHover=${rgb v.mint}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundLink=${rgb v.mint}
    ForegroundNegative=${rgb v.danger}
    ForegroundNeutral=${rgb v.warning}
    ForegroundNormal=${rgb v.text}
    ForegroundPositive=${rgb v.emerald}
    ForegroundVisited=${rgb v.lavender}

    [Colors:Selection]
    BackgroundAlternate=${rgb v.hover}
    BackgroundNormal=${rgb v.selection}
    DecorationFocus=${rgb v.mint}
    DecorationHover=${rgb v.mint}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundLink=${rgb v.mint}
    ForegroundNegative=${rgb v.danger}
    ForegroundNeutral=${rgb v.warning}
    ForegroundNormal=${rgb v.text}
    ForegroundPositive=${rgb v.emerald}
    ForegroundVisited=${rgb v.lavender}

    [Colors:Tooltip]
    BackgroundAlternate=${rgb v.canvas}
    BackgroundNormal=${rgb v.elev}
    DecorationFocus=${rgb v.mint}
    DecorationHover=${rgb v.mint}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundLink=${rgb v.mint}
    ForegroundNegative=${rgb v.danger}
    ForegroundNeutral=${rgb v.warning}
    ForegroundNormal=${rgb v.text}
    ForegroundPositive=${rgb v.emerald}
    ForegroundVisited=${rgb v.lavender}

    [Colors:View]
    BackgroundAlternate=${rgb v.elev}
    BackgroundNormal=${rgb v.canvas}
    DecorationFocus=${rgb v.mint}
    DecorationHover=${rgb v.mint}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundLink=${rgb v.mint}
    ForegroundNegative=${rgb v.danger}
    ForegroundNeutral=${rgb v.warning}
    ForegroundNormal=${rgb v.text}
    ForegroundPositive=${rgb v.emerald}
    ForegroundVisited=${rgb v.lavender}

    [Colors:View][Inactive]
    BackgroundNormal=${rgb v.canvas}
    ForegroundNormal=${rgb lt.text2}

    [Colors:Window]
    BackgroundAlternate=${rgb v.elev}
    BackgroundNormal=${rgb v.canvas}
    DecorationFocus=${rgb v.mint}
    DecorationHover=${rgb v.mint}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundLink=${rgb v.mint}
    ForegroundNegative=${rgb v.danger}
    ForegroundNeutral=${rgb v.warning}
    ForegroundNormal=${rgb v.text}
    ForegroundPositive=${rgb v.emerald}
    ForegroundVisited=${rgb v.lavender}

    [Colors:Header]
    BackgroundAlternate=${rgb v.elev}
    BackgroundNormal=${rgb v.elev}
    ForegroundActive=${rgb v.text}
    ForegroundInactive=${rgb lt.text2}
    ForegroundNormal=${rgb v.text}

    [General]
    ColorScheme=ArtlausNeon
    Name=Verdant / Living Terminal
    shadeSortColumn=true

    [KDE]
    contrast=0

    [WM]
    activeBackground=${rgb v.canvas}
    activeBlend=${rgb v.canvas}
    activeForeground=${rgb v.text}
    inactiveBackground=${rgb v.canvas}
    inactiveBlend=${rgb v.canvas}
    inactiveForeground=${rgb v.text}
  '';

  # qt6ct: 21 роль QPalette в порядке Qt (WindowText … PlaceholderText)
  activePalette = map argb [
    v.text        # WindowText
    v.elev        # Button
    v.hover       # Light
    v.elev        # Midlight
    lt.deep       # Dark
    v.canvas      # Mid
    v.text        # Text
    v.text        # BrightText
    v.text        # ButtonText
    v.canvas      # Base
    v.canvas      # Window
    lt.deep       # Shadow
    v.selection   # Highlight
    v.text        # HighlightedText
    v.mint        # Link
    v.lavender    # LinkVisited
    v.elev        # AlternateBase
    v.canvas      # NoRole
    v.elev        # ToolTipBase
    v.text        # ToolTipText
    v.muted       # PlaceholderText
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
      name = "Verdant";
      package = verdantGtk;
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

  # Файл уже существовал до перехода на HM: разрешаем декларативную перезапись.
  xdg.configFile."Kvantum/ArtlausNeon/ArtlausNeon.kvconfig" = {
    text = kvantumTheme;
    force = true;
  };
  xdg.configFile."Kvantum/ArtlausNeon/ArtlausNeon.svg".source = greenSvg;
  xdg.configFile."qt6ct/colors/ArtlausNeon.conf".text = qt6ctPalette;

  # gtk.iconTheme.package не создал активную XDG-ссылку — фиксируем явно.
  # Иконки доступны только для чтения, поэтому symlink на store здесь безопасен.
  home.file.".local/share/icons/Papirus-Green".source =
    "${greenIcons}/share/icons/Papirus-Green";

  xdg.dataFile."color-schemes/ArtlausNeon.colors".text = kdeColors;
  xdg.configFile."kdeglobals".text = ''
    ${kdeColors}

    [Icons]
    Theme=Papirus-Green
  '';
}
