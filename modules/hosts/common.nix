# Shared by every host
{inputs, ...}: {
  flake.modules.nixos.common = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.impermanence.nixosModules.impermanence
      inputs.sops-nix.nixosModules.sops
    ];

    environment.persistence."/persist".enable = lib.mkDefault (config.var.impermanenceEnabled or false);

    _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
