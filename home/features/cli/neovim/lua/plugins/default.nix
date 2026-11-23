{ config, pkgs, lib, theme, ... }:

let
  pluginFile = path: import path { inherit pkgs theme; };

  parsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    lua
    vim
    query
    bash
    json
    yaml
    toml
    nix
    markdown
    regex
    c
    cpp
    python
    javascript
    typescript
    html
    css
    rust
  ];

  configuredPlugins = [
    (pluginFile ./alpha.nix)
    (pluginFile ./autopairs.nix)
    (pluginFile ./bufferline.nix)
    (pluginFile ./cmp.nix)
    (pluginFile ./colorizer.nix)
    (pluginFile ./comment.nix)
    (pluginFile ./formatting-linting.nix)
    (pluginFile ./langmapper.nix)
    (pluginFile ./lsp.nix)
    (pluginFile ./lspsaga.nix)
    (pluginFile ./lualine.nix)
    (pluginFile ./markdown.nix)
    (pluginFile ./noice.nix)
    (pluginFile ./telescope.nix)
    (pluginFile ./treesitter.nix)
    (pluginFile ./yazi.nix)
  ];
in
{
  programs.neovim.plugins =
    (builtins.concatLists configuredPlugins)
    ++ (with pkgs.vimPlugins; [
      vim-tmux-navigator
      plenary-nvim
      nvim-web-devicons
      nvim-notify
      nui-nvim
      cmp-nvim-lsp
      luasnip
      cmp_luasnip
      lspkind-nvim
      cmp-cmdline
      cmp-path
      nvim-ts-context-commentstring
      telescope-fzf-native-nvim
      telescope-zoxide
    ])
    ++ parsers;
}
