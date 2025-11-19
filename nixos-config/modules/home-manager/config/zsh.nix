{ config, pkgs, ... }:

let
  # Function to generate FZF options string
  fzfDefaultOpts = ''
    --color=bg+:#000000,bg:#000000,spinner:#66FF99,hl:#55BBAA
    --color=fg:#66FF99,header:#55BBAA,info:#66FF99,pointer:#55BBAA
    --color=marker:#66FF99,fg+:#99FFBB,prompt:#55BBAA,hl+:#66FF99
    --layout=reverse --border --height=40%
  '';

  # Custom Zsh function for zoxide + fzf integration
  ziFzfFunction = ''
    __zi_fzf() {
      local dir
      dir=$(zoxide query -l | fzf --height 40% --border --reverse --prompt="Jump to   " --color=16 --ansi)
      if [[ -n "$dir" ]]; then
        cd "$dir" || return
      fi
    }
  '';

in {
  programs.zsh = {
    enable = true;
    enableCompletion = true; # Equivalent to setopt AUTO_CD

    # Environment Variables
    initExtra = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      export STARSHIP_CONFIG="$HOME/.config/starship.toml"
      export GOOGLE_CLOUD_PROJECT="data-avatar-475416-s2"

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }
    '';

    # History Settings
    history = {
      expireDuplicates = true; # Equivalent to setopt HIST_IGNORE_DUPS
      extended = true;
      path = "${config.home.homeDirectory}/.zsh_history";
      save = 50000;
      size = 50000;
    };
    
    # Zsh options
    shellAliases = {
      # === Редакторы ===
      vi = "nvim";
      # === Файловый менеджер ===
      y = "yazi";
      # === Git ===
      g = "lazygit";
      lg = "lazygit";
      d = "delta";
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push";
      # === Мониторинг ===
      top = "btop";
      bt = "btop";
      htop = "btop";
      # === JSON ===
      jq = "jq";
      jj = "jq";
      # === HTTP ===
      h = "http";
      http = "http";
      # === Навигация ===
      zo = "z";
      # === Поиск ===
      rg = "rg";
      rgg = "rg --hidden --glob "!.git"";
      # === Утилиты ===
      cle = "clear";
      ".." = "cd ..";
      "..." = "cd ../..";
      # Other aliases
      ll = "ls -la --color=auto";
      la = "ls -A";
      l = "ls -CF";
    };

    # Zsh options
    ohMyZsh = {
      enable = true; # Enable Oh My Zsh framework
      plugins = [ "git" ]; # ohmyzsh/ohmyzsh path:plugins/git
    };

    # Plugins managed by Antidote
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "v0.34.0"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "rupa";
          repo = "z";
          rev = "v1.10"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.8.0"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
      {
        name = "zsh-autopair";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "v0.2.0"; # Use a specific version for reproducibility
          sha256 = "sha256-y/1+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0+0="; # Update this with actual hash
        };
      }
    ];

    # Custom functions
    initExtraFirst = ''
      autoload -U colors && colors
      setopt CORRECT
      setopt NO_BEEP
      bindkey -e
    '';

    # Zoxide integration
    # home-manager has a dedicated option for zoxide
    # programs.zoxide.enable = true; # This will be enabled in artlaus/default.nix

    # FZF integration
    programs.fzf = {
      enable = true;
      defaultOptions = fzfDefaultOpts;
      # Custom FZF function for zoxide integration
      initExtra = ziFzfFunction;
    };

    # NVM (Node Version Manager) - NixOS manages Node.js versions declaratively.
    # Using NVM on NixOS is generally discouraged.
    # If you need specific Node.js versions, consider using `nix-shell` or `nix develop`
    # with appropriate `nodejs` packages.
    # The following lines are commented out as they are not idiomatic for NixOS.
    # export NVM_DIR="$HOME/.nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  };

  # Packages that should be installed for Zsh and its plugins
  home.packages = with pkgs; [
    starship # For the prompt
    zoxide # For directory navigation
    fzf # For fuzzy finding
    lazygit # Git TUI
    delta # Git diff viewer
    btop # System monitor
    jq # JSON processor
    httpie # HTTP client
    ripgrep # rg for searching
  ];
}
