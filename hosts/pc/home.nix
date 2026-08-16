# milotek-pc-linux: shared graphical profile + this machine's specifics.
{pkgs, ...}: {
  imports = [
    ../../home/graphical.nix

    # Apps that depend on this host's sops secrets. Add these to another host's
    # home.nix once that host has its own secrets provisioned.
    ../../home/programs/git/signing.nix # signing key from sops
    ../../home/programs/opencode # router-api-key from sops
    ../../home/programs/rclone # copyparty-password from sops

    ./variables.nix # Mostly user-specific configuration
    ./secrets # You should probably remove this line, this is where I store my secrets
  ];

  home.file.".face".source = ./profile_picture.png;

  home.packages = [pkgs.unityhub];

  # Dual 1440p144 desktop displays.
  wayland.windowManager.hyprland.settings.monitor = [
    "HDMI-A-1,2560x1440@144,0x0,1"
    "DP-1,2560x1440@144,2560x0,1"
  ];
}
