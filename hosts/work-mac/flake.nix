# nix-darwin host for the work MacBook (milotek-mac, Apple Silicon).
# Deploy with: darwin-rebuild switch --flake ~/.config/nixos#work-mac
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
