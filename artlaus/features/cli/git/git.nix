{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "ART-Laus"; # Из .gitconfig
    userEmail = "yzen26431@gmail.com"; # Из .gitconfig
    editor = "vim"; # Из core.editor в .gitconfig

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
        # excludesfile = "~/.gitignore_global"; # Это обрабатывается programs.git.ignores
        # editor = "vim"; # Это обрабатывается programs.git.editor
      };
      color = {
        ui = "auto";
      };
      color.branch = {
        current = "#FF007C"; # Ярко-розовый
        local = "#FFD500";   # Желтый
        remote = "#00FF9F";  # Ярко-зеленый
      };
      color.diff = {
        meta = "#00BFFF";    # Голубой
        frag = "#B400FF";    # Пурпурный
        old = "#FF007C";     # Ярко-розовый для удаленного
        new = "#00FF9F";     # Ярко-зеленый для добавленного
      };
      color.status = {
        added = "#00FF9F";     # Добавлено в индекс -> зеленый
        changed = "#FFD500";    # Изменено, но не в индексе -> желтый
        untracked = "#00BFFF";  # Неотслеживаемые файлы -> голубой
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
