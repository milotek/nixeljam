{config, ...}: {
  imports = [
    ./_hardware-configuration.nix
    ./_variables.nix
  ];

  home-manager.users."${config.nixeljam.username}" = import ./_home.nix;

  # User password
  users.users.${config.nixeljam.username}.initialPassword = "changeme"; # CHANGEME: run `passwd` after the first login

  # Don't touch this
  system.stateVersion = "26.05";
}
