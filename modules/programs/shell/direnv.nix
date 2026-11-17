{aspects, ...}: {
  flake.modules.nixos.shell.imports = [aspects.home-manager];
  flake.modules.nixos.shell.home-manager.sharedModules = [
    {
      programs.direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
      };
    }
  ];
}
