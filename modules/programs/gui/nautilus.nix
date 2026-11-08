# Nautilus: file manager
{
  flake.modules.nixos.nautilus.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.nautilus];
      }
    )
  ];
}
