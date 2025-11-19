{ config, pkgs, ... }:

{
  programs.yazi.theme = {
    flavor = "custom";
    # Colors from artgreendream.lua
    # bg        = "NONE",      -- transparent background
    # fg        = "#66FF99",   -- main text (green)
    # lavender  = "#C4A0FF",   -- keywords
    # cyan      = "#88ddff",   -- functions / methods / operators
    # yellow    = "#FFD966",   -- classes / types / warnings
    # blue      = "#3399FF",   -- numbers / booleans
    # pink      = "#FF66CC",   -- strings
    # turquoise = "#009999",   -- visual selection
    # red       = "#FF3355",   -- errors
    # gray      = "#3D6655",   -- comments
    # darkgray  = "#0D3322",   -- cursor, line highlight

    # Mapping to Yazi theme elements
    # This is a simplified mapping, more detailed customization is possible
    # based on Yazi's theme.toml structure.
    # For full customization, refer to Yazi's theme documentation.

    # General UI
    ui.bg = "none"; # Transparent background
    ui.fg = "#66FF99"; # Main text

    # Status line
    status.bg = "#111111";
    status.fg = "#66FF99";

    # Selected item
    selected.fg = "#000000";
    selected.bg = "#009999"; # Turquoise

    # Hovered item
    hovered.fg = "#000000";
    hovered.bg = "#FFD966"; # Yellow

    # Current line
    current.bg = "#0D3322"; # Darkgray

    # Highlighted text (e.g., search results)
    highlight.fg = "#000000";
    highlight.bg = "#FFD966"; # Yellow

    # Errors
    error.fg = "#FF3355"; # Red

    # Warnings
    warn.fg = "#FFD966"; # Yellow

    # Info
    info.fg = "#C4A0FF"; # Lavender

    # Hints
    hint.fg = "#88ddff"; # Cyan

    # Comments
    comment.fg = "#3D6655"; # Gray

    # Keywords
    keyword.fg = "#C4A0FF"; # Lavender

    # Functions
    function.fg = "#88ddff"; # Cyan

    # Strings
    string.fg = "#FF66CC"; # Pink

    # Numbers
    number.fg = "#3399FF"; # Blue

    # Booleans
    boolean.fg = "#3399FF"; # Blue

    # Variables
    variable.fg = "#66FF99"; # Main text

    # Types
    type.fg = "#FFD966"; # Yellow

    # Operators
    operator.fg = "#88ddff"; # Cyan

    # Diff
    diff.plus = "#00FF88";
    diff.minus = "#FF3355";
    diff.delta = "#88ddff";
  };
}
