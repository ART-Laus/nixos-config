{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
  cfg = config.artlaus.cli;
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;

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
          --color=bg+:#000000,bg:#000000,spinner:${c.primary},hl:${c.seaGreen}
          --color=fg:${c.primary},header:${c.seaGreen},info:${c.primary},pointer:${c.seaGreen}
          --color=marker:${c.primary},fg+:${c.lightGreen},prompt:${c.seaGreen},hl+:${c.primary}
          --layout=reverse --border --height=40%
        '';
      };

      # История
      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        extended = true;
        path = "${config.home.homeDirectory}/.zsh_history";
        size = 50000;
      };

      # Oh My Zsh с плагинами
      oh-my-zsh = {
        enable = true;
        plugins = [
          "zsh-autosuggestions"
          "zsh-completions"
          "fast-syntax-highlighting"
          "zsh-autopair"
          "zsh-you-should-use"
        ];
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

      # Дополнительный код Zsh (initContent — новые setopt + интеграции)
      initContent = ''
        # Zsh опции
        setopt correct
        unsetopt beep

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
          IFS= read -r -d '''' cwd < "$tmp"
          [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
        }
      '';
    };
  };
}
