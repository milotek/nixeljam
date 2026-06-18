{
  inputs,
  nixpkgs,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  modules = [
    {_module.args = {inherit inputs;};}
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ./configuration.nix
  ];
}
