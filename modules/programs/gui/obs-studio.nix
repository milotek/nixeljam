# OBS Studio: screen recording and streaming
{
  flake.modules.nixos.obs-studio.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.obs-studio];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/obs-studio"
          ];
        };
      }
    )
  ];
}
