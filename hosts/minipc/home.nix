{config, ...}: {
  imports = [
    # Programs
    ../../home/programs/ghostty
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/git
    ../../home/programs/git/lazygit.nix
    ../../home/programs/nix-utils
    ../../home/programs/yazi
    ../../home/programs/nixy

    ../../home/programs/group/basic-apps.nix
    ../../home/programs/group/dev.nix

    # Desktop
    ../../home/system/hyprland
    ../../home/system/caelestia-shell
    ../../home/system/hyprpaper
    ../../home/system/mime
    ../../home/system/udiskie

    ./variables.nix
    ./secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "24.05";
  };

  programs = {
    home-manager.enable = true;
    nixy = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
