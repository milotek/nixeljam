# Nix configuration for NixOS
{inputs, ...}: {
  flake.modules.nixos.nix = {config, ...}: let
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

    nix = {
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      channel.enable = false;
      extraOptions = ''
        warn-dirty = false
      '';
      settings = {
        download-buffer-size = 262144000; # 250 MB (250 * 1024 * 1024)
        auto-optimise-store = true;
        trusted-users = [config.var.username];
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
  };
}
