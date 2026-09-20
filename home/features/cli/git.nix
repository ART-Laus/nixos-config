{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.git = {
    enable = true;
    userName = "ART-Laus";
    userEmail = "yzen26431@gmail.com";

    # Глобальные игнорирования из .gitignore_global
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

    # Алиасы из .gitconfig
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
      br = "branch";
      hist = "log --all --graph --decorate --oneline -n30";
      type = "cat-file -t";
      dump = "cat-file -p";
    };

    # Дополнительные настройки Git из .gitconfig
    extraConfig = {
      core = {
        editor = "nvim";
      };
      color = {
        ui = "auto";
      };
      color.branch = {
        current = c.error;
        local = c.warning;
        remote = c.success;
      };
      color.diff = {
        meta = c.accentBlue;
        frag = c.secondary;
        old = c.error;
        new = c.success;
      };
      color.status = {
        added = c.success;
        changed = c.warning;
        untracked = c.accentBlue;
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
