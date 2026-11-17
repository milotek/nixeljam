# Loupe: image viewer
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.loupe = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.loupe];

        xdg.mimeApps = mime.defaultFor "org.gnome.Loupe.desktop" mime.types.image;
      })
    ];
  };
}
