# File Roller: archive manager
{
  flake.modules.nixos.file-roller.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.file-roller];
      }
    )
  ];
}
