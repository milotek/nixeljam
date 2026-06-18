# Standalone Home Manager for the restricted work Mac (milotek-mac.roam.internal).
# Keeps nix footprint minimal — no system-level nix-darwin required.
# Deploy with: home-manager switch --flake .#"milotek@milotek-mac"
{
  inputs,
  nixpkgs,
  ...
}:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages."aarch64-darwin";
  extraSpecialArgs = {inherit inputs;};
  modules = [./home.nix];
}
