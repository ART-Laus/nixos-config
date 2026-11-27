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

        # --- FZF / search integration ---
        FZF_DEFAULT_OPTS = ''
          --color=bg+:${c.bgAlt},bg:${c.bg},spinner:${c.primary},hl:${c.seaGreen}
          --color=fg:${c.fg},header:${c.seaGreen},info:${c.primary},pointer:${c.seaGreen}
          --color=marker:${c.primary},fg+:${c.fg},prompt:${c.seaGreen},hl+:${c.primary}
          --layout=reverse --border --height=40% --info=inline --cycle
        '';
        _ZO_FZF_OPTS = "$FZF_DEFAULT_OPTS --preview 'lsd --tree --depth=2 --color=always {2..} | head -200'";
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
          # --- Modern CLI replacements ---
          ls = "lsd";
          ll = "lsd -lah --group-dirs=first";
          la = "lsd -A --group-dirs=first";
          l = "lsd -F --group-dirs=first";
          lt = "lsd --tree --depth=2 --group-dirs=first";
          lta = "lsd --tree --depth=2 -A --group-dirs=first";
          cat = "bat --paging=never";
          batp = "bat"; # bat with pager
          grep = "rg";
          find = "fd";

          # --- Navigation / zoxide ---
          # `cd` is replaced by zoxide via `programs.zoxide.options = [ "--cmd" "cd" ]`.
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          cdi = "cdi"; # zoxide interactive picker (provided by zoxide init --cmd cd)

          # --- Editors / Git ---
          vi = "nvim";
          v = "nvim";
          g = "lazygit";
          lg = "lazygit";
          d = "delta";
          gs = "git status";
          ga = "git add .";
          gc = "git commit -m";
          gp = "git push";
          rgg = "rg --hidden --glob '!.git'";

          # --- System / monitoring ---
          top = "btop";
          bt = "btop";
          htop = "btop";
          disk = "dysk -u binary --bar-width 10";
          neofetch = "fastfetch";

          # --- Utilities ---
          jj = "jq";
          h = "http";
          cle = "clear";
          aln = "cd ~/Documents/ALN && nvim";
          nn = "new-note";

          # --- Containers ---
          docker = "podman";
          docker-compose = "podman-compose";

          # --- NixOS / flake management ---
          rbs = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
          rbb = "sudo nixos-rebuild boot --impure --flake ${flakeDir}";
          upg = "sudo nixos-rebuild switch --impure --upgrade --flake ${flakeDir}";
          upd = "sudo nix flake update --flake ${flakeDir}";
          grb = "sudo nix-collect-garbage -d";
          pkgs = "nvim ${flakeDir}/system/packages.nix";
          t = "timer";

          # --- Automation Layer ---
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
