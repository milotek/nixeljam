# Shared Home Manager profile for any graphical (non-headless) host.
# This is the full desktop experience - Hyprland + caelestia shell + the
# standard app suite. Graphical hosts import this and only add genuinely
# machine-specific bits (variables, secrets, monitors, GPU quirks, face).
#
# Apps that need per-host sops secrets (opencode, rclone, signed git commits)
# are intentionally NOT here - each host imports them from its own home.nix
# once its secrets are provisioned.
{config, ...}: {
  imports = [
    # Programs
    ./programs/chrome
    ./programs/proton
    ./programs/proton/auto-start-vpn.nix
    ./programs/ghostty
    ./programs/nvf
    ./programs/shell
    ./programs/git
    ./programs/git/lazygit.nix
    ./programs/thunar
    ./programs/nixy
    ./programs/nightshift
    ./programs/nix-utils
    ./programs/blender
    ./programs/godot
    ./programs/roblox
    ./programs/spotatui
    ./programs/spotify
    ./programs/yazi
    ./programs/zellij
    ./programs/ai
    ./programs/rofi

    ./programs/group/basic-apps.nix
    ./programs/group/cybersecurity.nix
    ./programs/group/dev.nix
    ./programs/group/misc.nix

    # System (Desktop environment like stuff)
    ./system/hyprland
    ./system/gpu-screen-recorder
    ./system/remote-desktop
    ./system/caelestia-shell
    ./system/hyprpaper
    ./system/mime
    ./system/udiskie
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    # Don't touch this
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
