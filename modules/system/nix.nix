# Nix configuration for NixOS
{
  aspects,
  inputs,
  ...
}: {
  flake.modules.nixos.nix = {
    config,
    lib,
    ...
  }: {
    imports = [aspects.common];

    # Faster rebuilding
    documentation = {
      doc.enable = false;
      dev.enable = false;
      info.enable = false;
      nixos.enable = false;
    };

    nixpkgs.config = {
      allowUnfree = true;
      allowBroken = false;
    };
    nix = {
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
      };
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
          "https://cache.numtide.com"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
      gc = {
        automatic = lib.mkDefault true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    system.autoUpgrade = {
      enable = lib.mkDefault false;
      dates = "04:00";
      flake = config.nixeljam.configDirectory;
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      allowReboot = false;
    };
  };
}
