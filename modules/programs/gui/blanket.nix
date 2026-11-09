# Blanket: background sounds
{
  flake.modules.nixos.blanket.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.blanket];
      }
    )
  ];
}
