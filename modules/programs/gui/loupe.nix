# Loupe: image viewer
{
  flake.modules.nixos.loupe.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.loupe];
      }
    )
  ];
}
