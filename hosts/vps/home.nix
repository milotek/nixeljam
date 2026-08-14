{config, ...}: {
  imports = [
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/nix-utils
    ./variables.nix
    # ./secrets is a system-level sops module (imported by configuration.nix),
    # not a home-manager one — don't import it here.
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
