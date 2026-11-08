# Google Chrome: web browser
{
  flake.modules.nixos.google-chrome.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.google-chrome];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/google-chrome"
          ];
        };
      }
    )
  ];
}
