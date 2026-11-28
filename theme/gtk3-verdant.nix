# theme/gtk3-verdant.nix — Verdant / Living Terminal GTK3 theme for GTK apps.
# Keeps adw-gtk3-dark as the structural base and replaces gtk.css with focused,
# purpose-split overrides driven by theme/colors.nix.
{ pkgs, colors, fonts, ... }:
let
  digit = ch: builtins.getAttr ch {
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
    "A" = 10;
    "B" = 11;
    "C" = 12;
    "D" = 13;
    "E" = 14;
    "F" = 15;
  };

  rgba = hex: alpha:
    let
      r = digit (builtins.substring 1 1 hex) * 16 + digit (builtins.substring 2 1 hex);
      g = digit (builtins.substring 3 1 hex) * 16 + digit (builtins.substring 4 1 hex);
      b = digit (builtins.substring 5 1 hex) * 16 + digit (builtins.substring 6 1 hex);
    in "rgba(${toString r},${toString g},${toString b},${alpha})";

  tokens = ''
    @define-color v_deep ${colors.deep};
    @define-color v_main ${colors.main};
    @define-color v_elevated ${colors.elevated};
    @define-color v_hover ${colors.hover};
    @define-color v_border ${colors.border};
    @define-color v_selection ${colors.selection};
    @define-color v_text ${colors.text};
    @define-color v_text2 ${colors.text2};
    @define-color v_muted ${colors.muted};
    @define-color v_mint ${colors.mint};
    @define-color v_emerald ${colors.emerald};
    @define-color v_sage ${colors.sage};
    @define-color v_lavender ${colors.lavender};
    @define-color v_warning ${colors.warning};
    @define-color v_danger ${colors.danger};
    @define-color v_shadow ${rgba colors.deep "0.72"};
    @define-color v_focus ${rgba colors.mint "0.20"};
  '';

  typography = builtins.replaceStrings
    [ "__UI_FONT__" "__UI_FONT_SIZE__" ]
    [ fonts.ui.name (toString fonts.ui.size) ]
    (builtins.readFile ./gtk3/80-typography.css);

  baseTheme = "${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark";

  cssFiles = [
    (pkgs.writeText "verdant-gtk3-tokens.css" tokens)
    ./gtk3/10-base.css
    ./gtk3/20-headerbar.css
    ./gtk3/30-sidebar.css
    ./gtk3/40-views.css
    ./gtk3/50-menus.css
    ./gtk3/60-dialogs.css
    ./gtk3/70-interactions.css
    (pkgs.writeText "verdant-gtk3-typography.css" typography)
  ];
in
pkgs.runCommand "verdant-gtk3" { } ''
  theme_dir="$out/share/themes/Verdant"
  mkdir -p "$theme_dir/gtk-3.0"
  cp -a ${baseTheme}/gtk-3.0/. "$theme_dir/gtk-3.0/"
  chmod -R u+w "$theme_dir/gtk-3.0"
  rm -f "$theme_dir/gtk-3.0/gtk.css" "$theme_dir/gtk-3.0/gtk-dark.css"

  cat ${baseTheme}/gtk-3.0/gtk.css ${builtins.concatStringsSep " " cssFiles} > "$theme_dir/gtk-3.0/gtk.css"
  cp "$theme_dir/gtk-3.0/gtk.css" "$theme_dir/gtk-3.0/gtk-dark.css"

  cat > "$theme_dir/index.theme" <<'EOF'
[X-GNOME-Metatheme]
Name=Verdant
Type=X-GNOME-Metatheme
Comment=Verdant / Living Terminal GTK3 theme
Encoding=UTF-8
GtkTheme=Verdant
EOF
''
