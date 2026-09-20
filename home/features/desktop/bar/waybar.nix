{ pkgs, theme, ... }:

{
  # Add the now.sh script package to home-manager's packages
  home.packages = [
    (import ./scripts { inherit pkgs; })
  ];

  programs.waybar = {
    enable = true;
    style = (import ./style.nix { inherit theme; });
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 0;
        height = 40;
        "margin-top" = 0;
        "modules-left" = [ "hyprland/workspaces" "memory" "cpu" "custom/nowplaying" ];
        "modules-right" = [ "tray" "clock" "battery" ];

        "hyprland/workspaces" = {
          format = "{name}";
          "format-icons" = {
            active = "";
            default = "";
          };
        };

        tray = { spacing = 5; };

        memory = {
          interval = 5;
          format = "{}% 󰍛";
          "min-length" = 7;
          "max-length" = 10;
        };

        cpu = {
          interval = 5;
          format = "{}% 󰍛";
          "min-length" = 7;
          "max-length" = 10;
        };

        battery = {
          format = "1{capacity}% {icon}";
          "format-icons" = [ "" "" "" "" "" ];
        };

        temperature = {
          "hwmon-path" = [
            "/sys/class/hwmon/hwmon2/temp1_input"
            "/sys/class/thermal/thermal_zone0/temp"
          ];
          format = "{temperatureC}°C ";
        };

        network = {
          format = "{ifname}";
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ifname} ";
          "format-disconnected" = "";
          "tooltip-format" = "{ifname}";
          "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
          "tooltip-format-ethernet" = "{ifname} ";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 50;
        };

        clock = {
          interval = 1;
          "tooltip-format" = "<tt>{calendar}</tt>";
          "format-alt" = "  {:%a, %d %b %Y}";
          format = "  {:%H:%M:%S}";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-bluetooth-muted" = "{icon} {format_source}";
          "format-muted" = "{format_source}";
          "format-source" = "";
          "format-source-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
        };

        "custom/nowplaying" = {
          format = " {}"; # Using a music icon
          interval = 15; # Check every 15 seconds
          exec = "now.sh";
          "max-length" = 50; # Truncate if the output is too long
        };
      };
    };
  };
}
