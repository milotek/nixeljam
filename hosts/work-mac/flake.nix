{
  inputs,
  nixpkgs,
  pkgs-unstable,
  ...
}:
inputs.nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = {inherit inputs pkgs-unstable;};
  modules = [
    inputs.home-manager.darwinModules.home-manager
    ./configuration.nix
  ];
}
