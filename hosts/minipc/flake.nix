{
  inputs,
  nixpkgs,
  pkgs-unstable,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    {
      nixpkgs.overlays = [
        inputs.nur.overlays.default
        inputs.nix-minecraft.overlay
      ];
      _module.args = {inherit inputs pkgs-unstable;};
    }
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.default
    inputs.nix-openclaw.nixosModules.openclaw-gateway
    inputs.hermes-agent.nixosModules.default
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./configuration.nix
  ];
}
