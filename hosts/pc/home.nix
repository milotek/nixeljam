{
  config,
  inputs,
  ...
}: {
  imports = [
    # Programs

    ## GUI
    ../../home/programs/gui/chrome
    ../../home/programs/gui/proton
    ../../home/programs/gui/proton/auto-start-vpn.nix
    ../../home/programs/gui/spotify
    ../../home/programs/gui/thunar
    ../../home/programs/gui/blender
    ../../home/programs/gui/godot
    ../../home/programs/gui/roblox
    ../../home/programs/gui/pkgs.nix

    ## TUI
    inputs.nvf-config.homeManagerModules.default
    ../../home/programs/tui/ghostty
    ../../home/programs/tui/shell
    ../../home/programs/tui/git
    ../../home/programs/tui/git/lazygit.nix
    ../../home/programs/tui/git/signing.nix
    ../../home/programs/tui/nixy
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/spotatui
    ../../home/programs/tui/yazi
    ../../home/programs/tui/zellij
    ../../home/programs/tui/opencode
    ../../home/programs/tui/rclone
    ../../home/programs/tui/ai
    ../../home/programs/tui/pkgs.nix

    ## GROUPS
    ../../home/programs/group/cybersecurity.nix
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
    ../../home/system/termfilechooser
    ../../home/system/udiskie
    ../../home/system/gpu-screen-recorder
    ../../home/system/remote-desktop

    ./variables.nix # Mostly user-specific configuration
    ./secrets # sops-managed home secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    file.".face" = {
      source = ./profile_picture.png;
    };

    # Don't touch this — existing install predates v6's 26.05 default.
    stateVersion = "24.05";
  };

  # pc's dual displays (per-host, per v6 convention).
  wayland.windowManager.hyprland.settings.monitor = [
    "HDMI-A-1,2560x1440@144,0x0,1"
    "DP-1,2560x1440@144,2560x0,1"
  ];

  programs = {
    home-manager.enable = true;
    nixy = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
