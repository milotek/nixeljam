# Udiskie is a simple daemon that uses udisks to automatically mount removable storage devices.
{aspects, ...}: {
  flake.modules.nixos.desktop.imports = [aspects.home-manager];
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    {
      services.udiskie = {
        enable = true;
        notify = false;
        automount = true;
        tray = "never";
      };
    }
  ];
}
