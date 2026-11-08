# Obsidian: note taking app
{
  flake.modules.nixos.obsidian.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.obsidian];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/obsidian"
          ];
        };
      }
    )
  ];
}
