{config, ...}: let
  username = config.nixeljam.username;
in {
  imports = [./_hardware-configuration.nix];

  # Don't touch this
  home-manager.users.${username}.home.stateVersion = "24.05";

  sops.defaultSopsFile = ./_secrets/secrets.yaml;

  # Mutable users only read hashedPasswordFile when the account is created
  users.mutableUsers = false;
  sops.secrets.user-password.neededForUsers = true;
  users.users.${username}.hashedPasswordFile = config.sops.secrets.user-password.path;

  # Don't touch this
  system.stateVersion = "24.05";
}
