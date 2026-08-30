# Note taking app, opening the ObsidianVault repo synced by the obsidian-git plugin
{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [(import ./package.nix {inherit pkgs lib config;})];
}
