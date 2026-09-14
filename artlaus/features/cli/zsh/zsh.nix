{ config, pkgs, lib, ... }:

let
  cfg = config.artlaus.cli;
  
  # Определение списка плагинов Zsh для Antidote
  zshPlugins = with pkgs; [
    # --- Ваши основные плагины ---
    { name = "zsh-autosuggestions"; src = zsh-users-zsh-autosuggestions; }
    { name = "zsh-completions"; src = zsh-users-zsh-completions; }
    { name = "fast-syntax-highlighting"; src = fast-syntax-highlighting; } # Быстрая подсветка синтаксиса
    { name = "zsh-autopair"; src = zsh-autopair; } # Авто-закрытие скобок

    # --- Навигация и Git ---
    { name = "zoxide"; src = oh-my-zsh.plugins.zoxide; } # Стандартизация на zoxide
    { name = "git"; src = oh-my-zsh.plugins.git; }

    # --- Плагины из референсного конфига ---
    { name = "bgnotify"; src = oh-my-zsh.plugins.bgnotify; } # Уведомления о завершении долгих команд
    { name = "colored-man-pages"; src = oh-my-zsh.plugins.colored-man-pages; } # Цветные man-страницы
    { name = "copypath"; src = oh-my-zsh.plugins.copypath; } # Копирование текущего пути
    { name = "dirhistory"; src = oh-my-zsh.plugins.dirhistory; } # Удобная навигация по истории каталогов (Alt+стрелки)
    { name = "extract"; src = oh-my-zsh.plugins.extract; } # 'extract <file>' для любой распаковки
    { name = "safe-paste"; src = oh-my-zsh.plugins.safe-paste; } # Безопасная вставка
    { name = "ssh-agent"; src = oh-my-zsh.plugins.ssh-agent; } # Автозапуск ssh-agent
    { name = "timer"; src = oh-my-zsh.plugins.timer; } # Показывает время выполнения команды
    { name = "universalarchive"; src = oh-my-zsh.plugins.universalarchive; } # 'ua <format> <file>' для упаковки
    { name = "fzf"; src = oh-my-zsh.plugins.fzf; } # Улучшенная интеграция fzf
    { name = "you-should-use"; src = zsh-you-should-use; } # Предлагает использовать алиасы
  ];
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true; # Включаем, но fast-syntax-highlighting будет иметь приоритет

      # Поиск по истории команд с учетом уже набранного текста
      historySubstringSearch = {
        enable = true;
        searchUpKey = [
          "^[[A"
          "$terminfo[kcuu1]"
        ];
        searchDownKey = [
          "^[[B"
          "$terminfo[kcud1]"
        ];
      };

      # Сессионные переменные
      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "nvim";
        VISUAL = "nvim";
        YAZI_CONFIG_HOME = "${config.home.homeDirectory}/.config/yazi";
        GOOGLE_CLOUD_PROJECT = "data-avatar-475416-s2";
        NVM_DIR = "${config.home.homeDirectory}/.nvm";
        FZF_DEFAULT_OPTS = ''
          --color=bg+:#000000,bg:#000000,spinner:#66FF99,hl:#55BBAA
          --color=fg:#66FF99,header:#55BBAA,info:#66FF99,pointer:#55BBAA
          --color=marker:#66FF99,fg+:#99FFBB,prompt:#55BBAA,hl+:#66FF99
          --layout=reverse --border --height=40%
        '';
      };

      # История
      history = {
        expireDuplicates = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        extended = true;
        path = "${config.home.homeDirectory}/.zsh_history";
        size = 50000;
      };

      # Zsh опции
      setopt = [
        "correct"
        "no_beep"
      ];

      # Oh My Zsh - включаем, но плагины через Antidote
      ohMyZsh = {
        enable = true;
      };

      # Antidote - менеджер плагинов
      # Явно указываем пакет, чтобы гарантировать установку через Nix.
      antidote = {
        enable = true;
        package = pkgs.antidote;
        plugins = zshPlugins;
      };

      # Алиасы
      shellAliases = let
        flakeDir = "${config.home.homeDirectory}/nixos-config"; # Исправлен путь
      in {
        # --- Ваши алиасы ---
        ll = "ls -la --color=auto";
        la = "ls -A";
        l = "ls -CF";
        vi = "nvim";
        y = "yazi"; 
        g = "lazygit";
        lg = "lazygit";
        d = "delta";
        gs = "git status";
        ga = "git add .";
        gc = "git commit -m";
        gp = "git push";
        top = "btop";
        bt = "btop";
        htop = "btop";
        jq = "jq";
        jj = "jq";
        h = "http";
        http = "http";
        cd = "z"; 
        rg = "rg";
        rgg = "rg --hidden --glob \"!.git\"";
        cle = "clear";
        ".." = "cd ..";
        "..." = "cd ../..";
        aln = "cd ~/Documents/ALN && nvim";
        nn = "/home/artlaus/scripts/new_note.sh";

        # --- Алиасы из референсного конфига ---
        rbs = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
        rbb = "sudo nixos-rebuild boot --impure --flake ${flakeDir}";
        upg = "sudo nixos-rebuild switch --impure --upgrade --flake ${flakeDir}";
        upd = "sudo nix flake update --flake ${flakeDir}";
        grb = "sudo nix-collect-garbage -d";
        pkgs = "nvim ${flakeDir}/nixos/packages.nix"; # Путь может потребовать корректировки
        t = "timer";
      };

      # Дополнительный код Zsh
      initExtra = ''
        # Интеграция zoxide для cd
        eval "$(zoxide init zsh)"

        # NVM setup
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        # FZF интерактивный переход по каталогам zoxide
        alias zi='__zi_fzf'

        __zi_fzf() {
          local dir
          dir=$(zoxide query -l | fzf --height 40% --border --reverse --prompt="Jump to   " --color=16 --ansi)
          if [[ -n "$dir" ]]; then
            cd "$dir" || return
          fi
        }

        # Кастомная функция для Yazi
        function y() {
          local tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")" cwd
          yazi "$@" --cwd-file="$tmp"
          IFS= read -r -d '' cwd < "$tmp"
          [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
        }
      '';
    };
  };
}
