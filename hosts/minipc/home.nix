{
  config,
  inputs,
  ...
}: {
  imports = [
    # Programs (lighter than pc — no creative/gaming/media tooling)

    ## GUI
    ../../home/programs/gui/chrome
    ../../home/programs/gui/pkgs.nix

    ## TUI
    inputs.nvf-config.homeManagerModules.default
    ../../home/programs/tui/ghostty
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/git/lazygit.nix
    ../../home/programs/tui/nixy
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/yazi
    ../../home/programs/tui/pkgs.nix

    ## GROUPS
    ../../home/programs/group/dev.nix

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/hyprlock
    ../../home/system/hypridle
    ../../home/system/waybar
    ../../home/system/swaync
    ../../home/system/tofi
    ../../home/system/clipboard
    ../../home/system/mime
    ../../home/system/udiskie

    ./variables.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    # Don't touch this — existing install predates v6's 26.05 default.
    stateVersion = "24.05";
  };

  # No machine-specific monitor override — minipc auto-detects displays
  # (v6 hyprland default: ",preferred,auto,1").

  programs = {
    home-manager.enable = true;
    nixy = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
