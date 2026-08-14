# Nix configuration for NixOS
{
  config,
  inputs,
  ...
}: let
  autoGarbageCollector = config.var.autoGarbageCollector;
in {
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  # Ask for password once per SSH session (tied to the tty, expires when session closes)
  security.sudo.extraConfig = ''
    Defaults timestamp_type=tty,timestamp_timeout=-1
  '';

  # Passwordless nixos-rebuild for the primary user (convenience on the rebuild workflow).
  security.sudo.extraRules = [
    {
      users = [config.var.username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nix = {
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    channel.enable = false;
    extraOptions = ''
      warn-dirty = false
    '';
    settings = {
      download-buffer-size = 262144000; # 250 MB (250 * 1024 * 1024)
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
