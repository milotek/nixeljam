# Shared by every host
{inputs, ...}: {
  flake.modules.nixos.common = {
    config,
    lib,
    ...
  }: {
    options.nixeljam = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Main user of the host";
      };

      configDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.nixeljam.username}/.config/nixos";
        description = "Path of this repository on the host";
      };
    };

    imports = [
      inputs.impermanence.nixosModules.impermanence
      inputs.sops-nix.nixosModules.sops
    ];

    # Features declare their state in /persist, it only takes effect with the impermanence aspect
    config.environment.persistence."/persist".enable = lib.mkDefault false;

    config.nixpkgs.overlays = [
      # An overlay rather than a module argument, so home-manager modules get pkgs.unstable too (useGlobalPkgs)
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
}
