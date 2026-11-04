{
  config,
  inputs,
  ...
}: {
  imports = [
    ../../home/programs/gui/chrome
    ../../home/programs/gui/pkgs.nix

    inputs.nvf-config.homeManagerModules.default
    ../../home/programs/tui/ghostty
    ../../home/programs/tui/zellij
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/git/lazygit.nix
    ../../home/programs/tui/git/signing.nix
    ../../home/programs/tui/nixy
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/ai
    ../../pkgs/tidyname
    ../../home/programs/tui/pkgs.nix

    ../../home/programs/group/dev.nix

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
    packages = [inputs.hermes-agent.packages.x86_64-linux.default];

    # Don't change: this install predates the 26.05 default.
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
