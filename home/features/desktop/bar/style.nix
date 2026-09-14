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
  background: #001a0d;
  color: #C0FFC0;
  border-bottom: 0px solid rgba(180, 0, 255, 0.3);
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
  color: rgba(255, 255, 255, 0.7);
  background: transparent;
  border-radius: 0;
  border: none;
  min-height: 30px;
  transition: all 0.3s ease;
}

#workspaces button:hover {
  background: rgba(180, 0, 255, 0.3);
  color: rgba(255, 255, 255, 0.7);
}

/* USER REQUEST: active workspace underlined with lavender and slightly darkened */
#workspaces button.active {
  background: rgba(192, 255, 192, 0.2); /* Slightly darkened/transparent foreground */
  color: #C0FFC0; /* Use main foreground color */
  box-shadow: inset 0 -3px 0 #CC66FF; /* Lavender underline */
}

/* USER REQUEST: urgent workspace flashes with accent green */
#workspaces button.urgent {
  background: #33FFB2;
  color: #001a0d;
  animation: pulse 1.5s infinite;
}

#tray {
  background: rgba(30, 30, 46, 0.5); /* color0 */
  margin: 4px 3px;
  padding: 0 12px;
  border-radius: 0;
  border: 1px solid rgba(180, 0, 255, 0.1); /* color5 */
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
  background: rgba(30, 30, 46, 0.7); /* color0 */
  color: rgba(180, 0, 255, 0.3); /* color5 */
  border-radius: 5px;
  border: 1px solid rgba(180, 0, 255, 0.1); /* color5 */
}

#clock {
  background: rgba(0, 26, 13, 0.5); /* background */
  color: #FFFFFF;
  font-weight: 800;
  margin-right: 8px;
  padding: 0 16px;
}

#pulseaudio {
  background: rgba(255, 213, 0, 0.6); /* color3 */
  color: #001a0d;
}

#network {
  background: rgba(0, 191, 255, 0.6); /* color4 */
  color: #001a0d;
}

#battery {
  background: rgba(0, 255, 255, 0.6); /* color6 */
  color: #001a0d;
}

#cpu {
  background: rgba(255, 0, 124, 0.6); /* color1 */
  color: #001a0d;
  margin-left: 8px;
}

#memory {
  background: rgba(0, 255, 159, 0.6); /* color2 */
  color: #001a0d;
}

#temperature {
  background: rgba(255, 213, 0, 0.6); /* color3 */
  color: #001a0d;
  margin-right: 4px;
}

#battery.charging {
  background: rgba(0, 255, 159, 0.7); /* Mapped to a green */
  color: #001a0d;
}

#battery.warning:not(.charging) {
  background: rgba(255, 213, 0, 0.7); /* Mapped to yellow */
  color: #001a0d;
}

#battery.critical:not(.charging) {
  background: rgba(255, 0, 124, 0.8); /* Mapped to red */
  color: #001a0d;
  animation: blink 1s linear infinite;
}

tooltip {
  background: rgba(0, 26, 13, 0.95);
  color: #C0FFC0;
  border: 1px solid rgba(180, 0, 255, 0.3);
  border-radius: 5px;
  padding: 12px;
}

tooltip label {
  color: #C0FFC0;
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