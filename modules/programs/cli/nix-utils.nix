{
  inputs,
  aspects,
  ...
}: {
  flake.modules.nixos.nix-utils = {
    imports = [
      inputs.nix-index-database.nixosModules.default
      aspects.home-manager
    ];

    home-manager.sharedModules = [
      (
        {inputs, ...}: {
          imports = [inputs.nix-index-database.homeModules.default];
          programs.nix-index.enable = true;
          programs.nix-index-database.comma.enable = true;
        }
      )
    ];
  };
}
