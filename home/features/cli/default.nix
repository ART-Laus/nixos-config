# home/features/cli/default.nix — агрегатор CLI кубиков
{
  imports = [
    ./shell/zsh.nix
    ./shell/starship.nix
    ./terminal/alacritty.nix
    ./terminal/kitty.nix
    ./git.nix
    ./yazi.nix
    ./tmux.nix
    ./fastfetch.nix
    ./neovim
    ./tools.nix
  ];
}
