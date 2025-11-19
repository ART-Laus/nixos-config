{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true; # Ensure Starship integrates with Zsh

    settings = {
      # Основной цвет — #66FF99 (неон-зелёный)
      format = ''
        [╭─](#66FF99)$status$username$directory$git_branch$git_status$cmd_duration
        [╰─>](#66FF99) ''';

      right_format = "$time";

      add_newline = true;

      # ----------------
      # Статус последней команды
      # ----------------
      status = {
        style = "bold #66FF99";
        symbol = "[✖](bold #FF5566) ";
        format = "[$symbol]($style)";
        success_symbol = "✔ ";
      };

      # ----------------
      # Имя пользователя
      # ----------------
      username = {
        show_always = true;
        style_user = "bold #99FFBB";
        format = "[$user]($style_user) ";
      };

      # ----------------
      # Текущая директория
      # ----------------
      directory = {
        truncation_length = 3;
        style = "bold #66DDCC";
        format = "[$path]($style) ";
      };

      # ----------------
      # Git
      # ----------------
      git_branch = {
        symbol = " ";
        style = "bold #55EE88";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold #55EE88";
        format = "([$all_status]($style)) ";
      };

      # ----------------
      # Время выполнения
      # ----------------
      cmd_duration = {
        min_time = 2000;
        style = "bold #55BBAA";
        format = "[⏱ $duration]($style) ";
      };

      # ----------------
      # Время и дата (справа)
      # ----------------
      time = {
        disabled = false;
        time_format = "%d.%m.%Y %H:%M";
        style = "bold #55BBAA";
        format = "[$time]($style)";
      };
    };
  };
}
