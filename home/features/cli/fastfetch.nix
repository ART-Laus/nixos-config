# 26.05: neofetch удалён (заброшен) → fastfetch. Алиас `neofetch` сохранён (zsh.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [ fastfetch ];
}
