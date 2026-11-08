# Flake-wide flake-parts settings
{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.modules # flake.modules.<class>.<name>
  ];

  # Helpers shared between modules, defined from several files (lib/*.nix)
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
  };

  config = {
    _module.args.aspects = config.flake.nixosModules;

    flake.nixosModules =
      lib.mapAttrs (name: module: {
        key = "nixeljam#aspects.${name}";
        imports = [module];
      })
      config.flake.modules.nixos;

    flake.templates.default = {
      path = ../../templates/default;
      description = "A machine built from nixeljam's bundles";
    };

    systems = ["x86_64-linux" "aarch64-linux"];
    perSystem = {
      pkgs,
      system,
      ...
    }: {
      formatter = pkgs.alejandra;
      devShells.default = import ../../shell.nix {
        inherit pkgs;
        gitHooksLib = inputs.git-hooks.lib.${system};
      };
    };
  };
}
