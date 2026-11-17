# Nautilus: file manager
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.nautilus = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.nautilus];

        xdg.mimeApps = mime.defaultFor "org.gnome.Nautilus.desktop" mime.types.directory;
      })
    ];
  };
}
