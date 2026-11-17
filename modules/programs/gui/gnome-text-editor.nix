# GNOME Text Editor
{aspects, ...}: {
  flake.modules.nixos.gnome-text-editor.imports = [aspects.home-manager];
  flake.modules.nixos.gnome-text-editor.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.gnome-text-editor];
      }
    )
  ];
}
