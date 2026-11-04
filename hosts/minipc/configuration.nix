{
  config,
  lib,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/tuigreet.nix
    ../../nixos/hyprland.nix
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/ydotool.nix
    ../../nixos/tailscale.nix
    ../../server-modules/ssh.nix

    ../../server-modules/adguardhome.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/copyparty.nix
    ../../server-modules/navidrome.nix
    ../../server-modules/slskd.nix
    ../../server-modules/home-assistant.nix
    ../../server-modules/glance
    ../../server-modules/zellij-web.nix
    ../../server-modules/pelican.nix
    ../../server-modules/site.nix
    ../../server-modules/habits.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  sops = {
    defaultSopsFile = ./secrets/system-secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets = {
      key = {
        path = "/home/${config.var.username}/.ssh/id_ed25519";
        owner = config.var.username;
        mode = "0400";
      };
      key-pub = {
        path = "/home/${config.var.username}/.ssh/id_ed25519.pub";
        owner = config.var.username;
        mode = "0444";
      };
    };
  };

  zramSwap.enable = true;

  # psd pins ~800M of tmpfs on this OOM-prone 7.6G host; keep it off.
  services.psd.enable = lib.mkForce false;

  fileSystems."/var/lib/copyparty" = {
    device = "/dev/disk/by-label/copyparty";
    fsType = "ext4";
    options = ["nofail"];
  };

  systemd.services.copyparty.unitConfig.RequiresMountsFor = ["/var/lib/copyparty"];
  systemd.services.navidrome.unitConfig.RequiresMountsFor = ["/var/lib/copyparty"];
  systemd.services.slskd.unitConfig.RequiresMountsFor = ["/var/lib/copyparty"];

  home-manager.users."${config.var.username}" = import ./home.nix;

  systemd.user.services.hermes-gateway = {
    overrideStrategy = "asDropin";
    path = ["/run/wrappers" "/etc/profiles/per-user/${config.var.username}" "/run/current-system/sw"];
  };

  system.stateVersion = "24.05";
}
