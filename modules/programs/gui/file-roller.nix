# File Roller: archive manager
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.file-roller = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.file-roller];

        xdg.mimeApps = mime.defaultFor "org.gnome.FileRoller.desktop" mime.types.archive;
      })
    ];
  };
}
