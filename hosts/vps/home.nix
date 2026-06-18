{config, ...}: {
  imports = [
    ../../home/programs/shell
    ../../home/programs/git
    ../../home/programs/nix-utils
    ./variables.nix
    ./secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
