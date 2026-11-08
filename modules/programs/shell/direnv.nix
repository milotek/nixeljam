{
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
