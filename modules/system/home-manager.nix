# Home-manager configuration for NixOS
{
  inputs,
  aspects,
  ...
}: {
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      aspects.common
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {
        inherit inputs;
      };
      sharedModules = [
        (
          {
            lib,
            osConfig,
            ...
          }: {
            # home.persistence entries are enabled by default, follow the system instead
            home.persistence."/persist".enable = lib.mkDefault osConfig.environment.persistence."/persist".enable;
          }
        )
      ];
    };
  };
}
