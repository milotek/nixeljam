{
  inputs,
  nixpkgs,
  pkgs-unstable,
  ...
}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    {_module.args = {inherit inputs pkgs-unstable;};}
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nixos-wsl.nixosModules.default
    ./configuration.nix
  ];
}
