{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./_secrets];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    # Kept here rather than in gui/pkgs.nix: minipc imports that file too, and
    # these closures (blender alone is ~4 GiB) would overflow its /nix/store.
    packages = with pkgs; [
      discord
      obs-studio
      blender
      godot
      unityhub
    ];

    file.".face" = {
      source = ./profile_picture.png;
    };

    # Don't touch this - existing install predates v6's 26.05 default.
    stateVersion = "24.05";
  };

  xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
    output "HDMI-A-1" {
        mode "2560x1440@144"
        position x=0 y=0
    }
    output "DP-1" {
        mode "2560x1440@144"
        position x=2560 y=0
    }
  '';

  programs = {
    home-manager.enable = true;
    njam = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
