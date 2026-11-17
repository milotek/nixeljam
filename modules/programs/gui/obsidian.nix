# Obsidian: note taking app
{aspects, ...}: {
  flake.modules.nixos.obsidian.imports = [aspects.home-manager];
  flake.modules.nixos.obsidian.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.obsidian];

        home.persistence."/persist" = {
          directories = [
            ".config/obsidian"
          ];
        };
      }
    )
  ];
}
