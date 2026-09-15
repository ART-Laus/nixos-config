{ theme, ... }:

let
  c = theme.colors;
in
''
* {
  border: none;
  border-radius: 0;
  font-family: JetBrainsMono Nerd Font, sans-serif;
  font-weight: bold;
  font-size: 14px;
  min-height: 0;
}

window#waybar {
  background: ${c.bg};
  color: ${c.fg};
  border-bottom: 0px solid rgba(196, 160, 255, 0.3);
  border-radius: 0;
  padding: 0;
  margin: 0;
}

#workspaces {
  margin: 0;
  padding: 0;
  border-radius: 0;
}

#workspaces button {
  padding: 0 16px;
  margin: 0;
  color: rgba(192, 255, 192, 0.7);
  background: transparent;
  border-radius: 0;
  border: none;
  min-height: 30px;
  transition: all 0.3s ease;
}

#workspaces button:hover {
  background: rgba(196, 160, 255, 0.3);
  color: rgba(192, 255, 192, 0.7);
}

#workspaces button.active {
  background: rgba(192, 255, 192, 0.2);
  color: ${c.fg};
  box-shadow: inset 0 -3px 0 ${c.secondary};
}

#workspaces button.urgent {
  background: ${c.success};
  color: ${c.bg};
  animation: pulse 1.5s infinite;
}

#tray {
  background: ${c.bgAltTransparent};
  margin: 4px 3px;
  padding: 0 12px;
  border-radius: 0;
  border: 1px solid rgba(196, 160, 255, 0.1);
}

#cpu,
#memory,
#temperature,
#pulseaudio,
#network,
#battery,
#clock,
#custom-notification {
  padding: 0 12px;
  margin: 4px 3px;
  background: ${c.bgAltTransparent};
  color: rgba(196, 160, 255, 0.3);
  border-radius: 5px;
  border: 1px solid rgba(196, 160, 255, 0.1);
}

#clock {
  background: ${c.bgTransparent};
  color: ${c.fg};
  font-weight: 800;
  margin-right: 8px;
  padding: 0 16px;
}

#pulseaudio {
  background: rgba(255, 213, 0, 0.6);
  color: ${c.bg};
}

#network {
  background: rgba(88, 214, 255, 0.6);
  color: ${c.bg};
}

#battery {
  background: ${c.cyan};
  color: ${c.bg};
}

#cpu {
  background: rgba(255, 85, 102, 0.6);
  color: ${c.bg};
  margin-left: 8px;
}

#memory {
  background: rgba(102, 255, 153, 0.6);
  color: ${c.bg};
}

#temperature {
  background: rgba(255, 213, 0, 0.6);
  color: ${c.bg};
  margin-right: 4px;
}

#battery.charging {
  background: rgba(102, 255, 153, 0.7);
  color: ${c.bg};
}

#battery.warning:not(.charging) {
  background: rgba(255, 213, 0, 0.7);
  color: ${c.bg};
}

#battery.critical:not(.charging) {
  background: rgba(255, 85, 102, 0.8);
  color: ${c.bg};
  animation: blink 1s linear infinite;
}

tooltip {
  background: ${c.bgTransparent};
  color: ${c.fg};
  border: 1px solid rgba(196, 160, 255, 0.3);
  border-radius: 5px;
  padding: 12px;
}

tooltip label {
  color: ${c.fg};
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.6; }
  100% { opacity: 1; }
}

@keyframes blink {
  0% { opacity: 1; }
  50% { opacity: 0.3; }
  100% { opacity: 1; }
}
''
