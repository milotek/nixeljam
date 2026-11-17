{aspects, ...}: {
  flake.modules.nixos.tidyname.imports = [aspects.home-manager];
  flake.modules.nixos.tidyname.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [
          (pkgs.writers.writePython3Bin "tidyname" {doCheck = false;} (builtins.readFile ./_tidyname.py))
        ];
      }
    )
  ];
}
