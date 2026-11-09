# Pinta: image editor
{
  flake.modules.nixos.pinta.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.pinta];
      }
    )
  ];
}
