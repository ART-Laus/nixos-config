{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    # You can add custom settings here if needed, e.g.:
    # policies = {
    #   DisableMasterPassword = true;
    #   ExtensionSettings = {
    #     "uBlock0@raymondhill.net" = {
    #       installation_mode = "force_installed";
    #       install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/addon-1037586-latest.xpi";
    #     };
    #   };
    # };
  };

  # Set Firefox as the default browser
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
  };
}
