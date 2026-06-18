{inputs, ...}:
inputs.nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    inputs.home-manager.darwinModules.home-manager
    ./configuration.nix
  ];
  specialArgs = {inherit inputs;};
}
