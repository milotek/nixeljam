{
  inputs,
  nixpkgs,
  ...
}:
nixpkgs.lib.nixosSystem {
  modules = [
    {_module.args = {inherit inputs;};}
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.sops-nix.nixosModules.sops
    ./configuration.nix
  ];
}
