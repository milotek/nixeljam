{config, ...}: {
  imports = [
    ../../home/programs/tui/shell
    ../../home/programs/tui/zellij
    ../../home/programs/tui/git
    ../../home/programs/tui/nix-utils
    ./variables.nix
    # Not ./secrets: it's a system-level sops module.
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
