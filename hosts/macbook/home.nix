{config, ...}: {
  imports = [
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/git
    ../../home/programs/git/lazygit.nix
    ../../home/programs/nix-utils
    ../../home/programs/yazi
    ../../home/programs/group/dev.nix
    ./variables.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/Users/" + config.var.username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
