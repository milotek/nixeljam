# XDG user directories (Documents, Downloads... plus Notes)
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    ({config, ...}: {
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        desktop = null;
        publicShare = null;
        templates = null;
        extraConfig = {
          NOTES = "${config.home.homeDirectory}/Notes";
        };
      };
    })
  ];
}
