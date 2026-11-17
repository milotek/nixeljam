# Home-manager configuration for NixOS
{
  aspects,
  inputs,
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
      extraSpecialArgs = {inherit inputs;};
      sharedModules = [
        ({osConfig, ...}: {
          programs.home-manager.enable = true;

          home.persistence."/persist".enable = osConfig.environment.persistence."/persist".enable;
        })
      ];
    };
  };
}
