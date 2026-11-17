# Secrets (sops-nix), shared by every host
{
  aspects,
  inputs,
  ...
}: {
  flake.modules.nixos.secrets = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      aspects.common
    ];
  };
}
