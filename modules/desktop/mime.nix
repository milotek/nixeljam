{aspects, ...}: {
  flake.modules.nixos.desktop.imports = [aspects.home-manager];
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    (
      {config, ...}: {
        xdg = {
          configFile."mimeapps.list".force = true;
          mimeApps.enable = true;

          userDirs = {
            enable = true;
            createDirectories = true;
            desktop = null;
            publicShare = null;
            templates = null;
            extraConfig = {
              NOTES = "${config.home.homeDirectory}/Notes";
            };
          };
        };
      }
    )
  ];
}
