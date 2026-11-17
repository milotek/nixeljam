# njam is a small menu to rebuild, test, update, collect garbage, clean the boot menu, etc.
#
# - `njam` - UI wizard to manage the system.
# - `njam rebuild` - Rebuild the system.
# - `njam ...` - ... see the script for more commands.
{aspects, ...}: {
  perSystem = {pkgs, ...}: {
    packages.njam = import ./_package.nix {
      inherit pkgs;
      configDirectory = "$HOME/.config/nixos";
    };
  };

  flake.modules.nixos.njam = {config, ...}: {
    imports = [
      aspects.common
      aspects.home-manager
    ];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [
          (import ./_package.nix {
            inherit pkgs;
            inherit (config.nixeljam) configDirectory;
          })
        ];
      })
    ];
  };
}
