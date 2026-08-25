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
      key = {
        path = "${home}/.ssh/id_ed25519";
      };
      "key.pub" = {
        path = "${home}/.ssh/id_ed25519.pub";
      };
      router-api-key = {};
      # copyparty (files.tek.rip) WebDAV password, consumed by the rclone mount.
      copyparty-password = {};
    };
  };

  home.file.".config/nixos/.sops.yaml".text = ''
    keys:
      - &primary age124lwwy8q48a6flvqnzcwc4a4n7q4ugl8a0qffzxj4m79z0qxk95s3695x5
      - &vps_host age1hxapnd4kqzcu3apsdy9zx6nwpwg0ztjlsguhkq553fnc7cmlzsqqeyq260
      - &pc_host age1fed7tsfrfvmee26qe604g4t5ptcugr78hkfrp6f2ld0ct3zu9yqqzmxnr7
      - &minipc_host age1ly67wnt5w03s29vr2c46n7ztsanwqtd8qw58sfh7xtz0y89fjgtq6k2trc
    creation_rules:
      - path_regex: hosts/pc/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/pc/secrets/system-secrets.yaml$
        key_groups:
          - age:
            - *primary
            - *pc_host
      - path_regex: hosts/minipc/secrets/system-secrets.yaml$
        key_groups:
          - age:
            - *primary
            - *minipc_host
      - path_regex: hosts/laptop/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/server/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
      - path_regex: hosts/vps/secrets/secrets.yaml$
        key_groups:
          - age:
            - *primary
            - *vps_host
  '';

  systemd.user.services.mbsync.Unit.After = ["sops-nix.service"];
  home.packages = with pkgs; [
    sops
    age
  ];

  wayland.windowManager.hyprland.settings.exec-once = ["systemctl --user start sops-nix"];
}
