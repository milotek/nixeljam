# OBS Studio: screen recording and streaming
{aspects, ...}: {
  flake.modules.nixos.obs-studio.imports = [aspects.home-manager];
  flake.modules.nixos.obs-studio.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.obs-studio];

        home.persistence."/persist" = {
          directories = [
            ".config/obs-studio"
          ];
        };
      }
    )
  ];
}
