# OnlyOffice: office suite
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.onlyoffice = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.onlyoffice-desktopeditors];

        xdg.mimeApps = mime.defaultFor "onlyoffice-desktopeditors.desktop" mime.types.office;
      })
    ];
  };
}
