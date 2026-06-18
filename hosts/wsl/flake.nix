{
  inputs,
  nixpkgs,
  system,
  pkgs-stable,
  pkgs-nur-hadi,
  ...
}:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs pkgs-stable pkgs-nur-hadi;
  };
  modules = [./home.nix];
}
