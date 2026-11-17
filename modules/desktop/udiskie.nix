# Udiskie is a simple daemon that uses udisks to automatically mount removable storage devices.
{
  flake.modules.nixos.desktop.services.udisks2.enable = true;
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
