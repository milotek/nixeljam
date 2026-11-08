# GNOME Text Editor
{
  flake.modules.nixos.gnome-text-editor.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.gnome-text-editor];
      }
    )
  ];
}
