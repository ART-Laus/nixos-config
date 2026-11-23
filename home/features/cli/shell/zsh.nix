{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
  cfg = config.artlaus.cli;

  omzCustom = pkgs.linkFarm "oh-my-zsh-custom" (
    map
      (p: {
        name = "plugins/${p.name}";
        path = p.path;
      }) [
      {
        name = "zsh-autosuggestions";
        path = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions";
      }
      {
        name = "fast-syntax-highlighting";
        path = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
      }
      {
        name = "you-should-use";
        path = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
      }
    ]
    ++ [
      {
        name = "plugins/zsh-autopair";
        path = pkgs.runCommand "zsh-autopair-omz" { } ''
          mkdir -p "$out"
          ln -s ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh "$out/zsh-autopair.plugin.zsh"
        '';
      }
      {
        name = "completions";
        path = "${pkgs.zsh-completions}/share/zsh/site-functions";
      }
    ]
  );
in
{
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;

      # Поиск по истории команд с учётом уже набранного текста
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
        FZF_DEFAULT_OPTS = ''
          --color=bg+:${c.bgAlt},bg:${c.bg},spinner:${c.primary},hl:${c.seaGreen}
          --color=fg:${c.fg},header:${c.seaGreen},info:${c.primary},pointer:${c.seaGreen}
          --color=marker:${c.primary},fg+:${c.fg},prompt:${c.seaGreen},hl+:${c.primary}
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

      # Oh My Zsh с плагинами из nixpkgs
      oh-my-zsh = {
        enable = true;
        plugins = [
          "zsh-autosuggestions"
          "fast-syntax-highlighting"
          "zsh-autopair"
          "you-should-use"
        ];
        custom = "${omzCustom}";
      };

      # Алиасы
      shellAliases =
        let
          flakeDir = "${config.home.homeDirectory}/nixos-config";
        in
        {
          ll = "ls -la --color=auto";
          la = "ls -A";
          l = "ls -CF";
          vi = "nvim";
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
          neofetch = "fastfetch";
          jj = "jq";
          h = "http";
          docker = "podman";
          docker-compose = "podman-compose";
          rgg = "rg --hidden --glob \"!.git\"";
          cle = "clear";
          ".." = "cd ..";
          "..." = "cd ../..";
          aln = "cd ~/Documents/ALN && nvim";
          nn = "new-note";

          rbs = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
          rbb = "sudo nixos-rebuild boot --impure --flake ${flakeDir}";
          upg = "sudo nixos-rebuild switch --impure --upgrade --flake ${flakeDir}";
          upd = "sudo nix flake update --flake ${flakeDir}";
          grb = "sudo nix-collect-garbage -d";
          pkgs = "nvim ${flakeDir}/system/packages.nix";
          t = "timer";

          # ── Automation Layer ──
          ex = "extract";
          ar = "archive";
          finfo = "fileinfo";
          sh = "share";
          dc = "doctor";
          nc = "nixcheck";
          qr = "make-qr";
          oc = "clip-ocr";
          td = "tidy-downloads";
          ir = "img-resize";
          ic = "img-compress";
          va = "vid2audio";
          vg = "vid2gif";
          pt = "pdf2text";
          br = "batch-rename";
          fdups = "find-duplicates";
          hf = "hashfile";
        };

      initContent = ''
        setopt correct
        unsetopt beep
      '';
    };
  };
}
