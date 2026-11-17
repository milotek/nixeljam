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
