# Google Chrome: web browser, default for web pages
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.google-chrome = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.google-chrome];

        xdg.mimeApps = mime.defaultFor "google-chrome.desktop" mime.types.browser;

        home.persistence."/persist".directories = [
          ".config/google-chrome"
        ];
      })
    ];
  };
}
