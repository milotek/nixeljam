# GNOME Text Editor
{aspects, ...}: {
  flake.modules.nixos.gnome-text-editor = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.gnome-text-editor];
      })
    ];
  };
}
