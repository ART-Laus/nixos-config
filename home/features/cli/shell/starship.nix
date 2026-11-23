{ theme, ... }:

let
  c = theme.colors;
in

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = ''
        [╭─](${c.primary})$status$username$directory$git_branch$git_status$nix_shell$rust$nodejs$python$golang$docker_context$cmd_duration
        [╰─>](${c.primary}) '';
      right_format = "$time";
      add_newline = true;

      status = {
        style = "bold ${c.primary}";
        symbol = "[✖](bold ${c.error}) ";
        format = "[$symbol]($style)";
        success_symbol = "✔ ";
      };

      username = {
        show_always = true;
        style_user = "bold ${c.lightGreen}";
        format = "[$user]($style_user) ";
      };

      directory = {
        truncation_length = 3;
        style = "bold ${c.mint}";
        format = "[$path]($style) ";
      };

      git_branch = {
        symbol = " ";
        style = "bold ${c.brightGreen}";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold ${c.brightGreen}";
        format = "([$all_status]($style)) ";
      };

      nix_shell = {
        symbol = "❄ ";
        style = "bold ${c.secondary}";
        format = "[$symbol$name]($style) ";
      };

      rust = {
        style = "bold ${c.warning}";
      };

      nodejs = {
        style = "bold ${c.lightGreen}";
      };

      python = {
        style = "bold ${c.accentBlue}";
      };

      golang = {
        style = "bold ${c.cyan}";
      };

      docker_context = {
        style = "bold ${c.info}";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold ${c.seaGreen}";
        format = "[⏱ $duration]($style) ";
      };

      time = {
        disabled = false;
        time_format = "%d.%m.%Y %H:%M";
        style = "bold ${c.seaGreen}";
        format = "[$time]($style)";
      };
    };
  };
}
