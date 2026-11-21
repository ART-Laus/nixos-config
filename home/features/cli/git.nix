{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.git = {
    enable = true;

    ignores = [
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      "*.bak"
      ".netrwhist"
      "sessions/"
      ".DS_Store"
      "._*"
      "Thumbs.db"
      "__pycache__/"
      "*.pyc"
      "*.pyo"
      "*.o"
      ".bundle/"
      ".vagrant/"
      "node_modules/"
      "*.log"
      "tags.temp"
      ".env"
      ".env.*"
      "!.env.example"
      "bin/stubs"
    ];

    settings = {
      user = {
        name = "ART-Laus";
        email = "yzen26431@gmail.com";
      };
      alias = {
        co = "checkout";
        ci = "commit";
        st = "status";
        br = "branch";
        hist = "log --all --graph --decorate --oneline -n30";
        type = "cat-file -t";
        dump = "cat-file -p";
      };
      core = {
        editor = "nvim";
      };
      color = {
        ui = "auto";
        branch = {
          current = c.error;
          local = c.warning;
          remote = c.success;
        };
        diff = {
          meta = c.accentBlue;
          frag = c.secondary;
          old = c.error;
          new = c.success;
        };
        status = {
          added = c.success;
          changed = c.warning;
          untracked = c.accentBlue;
        };
      };
      filter.lfs = {
        clean = "git-lfs clean %f";
        smudge = "git-lfs smudge %f";
        required = "true";
      };
      diff.sav = {
        textconv = "hexdump -v -C";
        binary = "true";
      };
    };
  };
}
