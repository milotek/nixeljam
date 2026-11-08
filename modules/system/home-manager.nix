# Home-manager configuration for NixOS
{inputs, ...}: {
  flake.modules.nixos.home-manager = {
    config,
    lib,
    pkgs-unstable,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {
        inherit inputs pkgs-unstable;
      };
      sharedModules = [
        {
          options = {
            var = lib.mkOption {
              type = lib.types.attrs;
              default = config.var;
            };
            theme = lib.mkOption {
              type = lib.types.attrs;
              default = config.theme;
            };
          };
        }
      ];
    };
  };
}
