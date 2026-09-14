{ pkgs, ... }:
{
  home.packages = with pkgs; [ neofetch fastfetch ];

  # neofetch config — was programs.neofetch in 23.11, removed in 25.05
  # Keep ASCII art as comment for reference
  # Original ascii art:
  # _,met$$$$$gg.
  # ,g$$$$$$$$$$$$$$$P.
  # etc.
}
