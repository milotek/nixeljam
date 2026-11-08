# OnlyOffice: office suite
{
  flake.modules.nixos.onlyoffice.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.onlyoffice-desktopeditors];
      }
    )
  ];
}
