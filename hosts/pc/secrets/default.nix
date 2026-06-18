# Those are my secrets, encrypted with sops
# You shouldn't import this file, unless you edit it
{
  inputs,
  pkgs,
  config,
  ...
}: let
  home = config.home.homeDirectory;
in {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    age.keyFile = "${home}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      ssh-config = {
        path = "${home}/.ssh/config";
      };
      github-key = {
        path = "${home}/.ssh/github";
      };
      signing-key = {
        path = "${home}/.ssh/key";
      };
      signing-pub-key = {
        path = "${home}/.ssh/key.pub";
      };
      oracle-key = {
        path = "${home}/.ssh/oracle";
      };
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age124lwwy8q48a6flvqnzcwc4a4n7q4ugl8a0qffzxj4m79z0qxk95s3695x5
    creation_rules:
      - path_regex: hosts/pc/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/laptop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/server/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [
    sops
    age
  ];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
