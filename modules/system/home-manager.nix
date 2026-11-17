# Home-manager configuration for NixOS
# Features add their user side through home-manager.sharedModules, hosts declare their user
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

          # Home paths declared with home.persistence stay inert unless the host imports the impermanence aspect
          home.persistence."/persist".enable = osConfig.environment.persistence."/persist".enable;
        })
      ];
    };
  };
}
