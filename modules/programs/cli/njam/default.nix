# njam is a small menu to rebuild, test, update, collect garbage, clean the boot menu, etc.
#
# - `njam` - UI wizard to manage the system.
# - `njam rebuild` - Rebuild the system.
# - `njam ...` - ... see the script for more commands.
{
  perSystem = {pkgs, ...}: {
    packages.njam = import ./_package.nix {
      inherit pkgs;
      configDirectory = "$HOME/.config/nixos";
    };
  };

  flake.modules.nixos.njam.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        options.programs.njam = {
          enable = lib.mkEnableOption "njam";
          configDirectory = lib.mkOption {
            type = lib.types.str;
            default = "$HOME/.config/nixos";
            description = "Path to the NixOS configuration directory";
          };
        };

        config = lib.mkIf config.programs.njam.enable {
          home.packages = [
            (import ./_package.nix {
              inherit pkgs;
              inherit (config.programs.njam) configDirectory;
            })
          ];
        };
      }
    )
  ];
}
