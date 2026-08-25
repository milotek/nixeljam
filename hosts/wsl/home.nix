{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nvf-config.homeManagerModules.default
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/git/lazygit.nix
    ../../home/programs/tui/zellij
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/nixy
    ../../home/programs/group/dev.nix

    ./variables.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "26.05";
  };

  programs = {
    home-manager.enable = true;
    nixy = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
