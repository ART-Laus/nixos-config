{ config, pkgs, ... }:

let
  # Helper to define plugins with fetchFromGitHub
  mkPlugin = { owner, repo, rev, sha256, ... } @args: {
    plugin = pkgs.vimPlugins.${repo} or (pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = repo;
      version = rev;
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev sha256;
      };
      # Add other args like meta, buildInputs if necessary
    });
  } // (removeAttrs args [ "owner" "repo" "rev" "sha256" ]);

  # Helper to define plugins that are already in pkgs.vimPlugins
  mkBuiltinPlugin = { name, ... } @args: {
    plugin = pkgs.vimPlugins.${name};
  } // (removeAttrs args [ "name" ]);

in {
  programs.neovim.plugins = [
    # Import individual plugin configurations
    (import ./alpha.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-autopairs.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./bufferline.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./cmp.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./colorizer.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./comment.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./conform.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./langmapper.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./lsp.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./lspsaga.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./lualine.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./mason.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./noice.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nui.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-autopairs.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-cmp.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-colorizer.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-lint.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-lspconfig.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-treesitter.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-ts-context-commentstring.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./nvim-web-devicons.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./plenary.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./supermaven.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./telescope-fzf-native.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./telescope-themes.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./telescope-zoxide.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./telescope.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
    (import ./yazi.nix { inherit config pkgs mkPlugin mkBuiltinPlugin; })
  ];
}
