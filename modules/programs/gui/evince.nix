# Evince: document viewer
{
  flake.modules.nixos.evince.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.evince];
      }
    )
  ];
}
