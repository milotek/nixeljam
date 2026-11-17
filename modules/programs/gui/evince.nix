# Evince: document viewer
{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.evince = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.evince];

        xdg.mimeApps = mime.defaultFor "org.gnome.Evince.desktop" mime.types.pdf;
      })
    ];
  };
}
