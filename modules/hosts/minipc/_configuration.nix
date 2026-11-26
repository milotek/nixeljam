{
  config,
  lib,
  ...
}: let
  username = config.nixeljam.username;
in {
  imports = [./_hardware-configuration.nix];

  home-manager.users.${username} = import ./_home.nix;

  sops.defaultSopsFile = ./_secrets/secrets.yaml;

  fileSystems.${config.nixeljam.media} = {
    device = "/dev/disk/by-label/copyparty";
    fsType = "ext4";
    options = ["nofail"];
  };

  zramSwap.enable = true;

  services.psd.enable = lib.mkForce false;

  programs.ydotool.enable = true;
  users.users.${username}.extraGroups = ["ydotool"];

  # Don't touch this
  system.stateVersion = "24.05";
}
