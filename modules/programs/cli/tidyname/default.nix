{aspects, ...}: {
  flake.modules.nixos.tidyname = {
    imports = [aspects.home-manager];

    nixpkgs.overlays = [
      (final: _: {
        tidyname = final.writers.writePython3Bin "tidyname" {doCheck = false;} (builtins.readFile ./_tidyname.py);
      })
    ];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.tidyname];
      })
    ];
  };
}
