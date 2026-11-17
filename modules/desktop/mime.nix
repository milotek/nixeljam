# Default applications: each app declares the MIME types it opens (lib/mime.nix)
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    {
      xdg = {
        configFile."mimeapps.list".force = true;
        mimeApps.enable = true;
      };
    }
  ];
}
