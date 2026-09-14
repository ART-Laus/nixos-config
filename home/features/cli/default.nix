# home/features/cli/default.nix — агрегатор CLI кубиков
{
  imports = [
    ./shell/zsh.nix
    ./shell/starship.nix
    ./terminal/wezterm.nix
    ./terminal/alacritty.nix
    ./git.nix
    ./yazi.nix
    ./tmux.nix
    ./neofetch.nix
    ./neovim
    ./tools.nix
  ];
}
