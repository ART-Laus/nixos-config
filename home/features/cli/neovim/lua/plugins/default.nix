{ pkgs, ... }:

{
  imports = [
    ./alpha.nix
    ./autopairs.nix
    ./bufferline.nix
    ./cmp.nix
    ./colorizer.nix
    ./comment.nix
    ./formatting-linting.nix
    ./langmapper.nix
    ./lsp.nix
    ./lspsaga.nix
    ./lualine.nix
    ./markdown.nix
    ./noice.nix
    ./telescope.nix
    ./treesitter.nix
    ./yazi.nix
  ];

  # This is where we define plugins that are NOT managed by lazy.nvim
  # These are usually vim plugins or dependencies that don't need a Lua config.
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-tmux-navigator # From tmux.nix
  ];
}