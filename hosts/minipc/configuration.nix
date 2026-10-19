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

    # Self-hosted services — add more from server-modules/ as needed
    ../../server-modules/adguardhome.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/copyparty.nix
    ../../server-modules/navidrome.nix
    ../../server-modules/slskd.nix
    ../../server-modules/home-assistant.nix
    ../../server-modules/openclaw.nix
    ../../server-modules/hermes.nix
    ../../server-modules/glance
    ../../server-modules/zellij-web.nix
    ../../server-modules/pelican.nix
    ../../server-modules/site.nix
    ../../server-modules/habits.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Reachable over the tailnet; the VPS's caddy proxies copyparty, navidrome,
  # slskd and home-assistant from there over TLS.

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

  # 7.6G of RAM, no swap and ~20 services left the kernel no way to reclaim idle
  # daemon pages, so it answered memory pressure by OOM-killing instead.
  # Compressed in RAM rather than a swapfile on disk: sda is a 2013 SATA SSD at
  # 86% full, where paging would be slow and spend write cycles this host
  # cannot spare. This box never hibernates, so it gives up nothing for it.
  zramSwap.enable = true;

  # Forced off against nixos/utils.nix, which enables psd for the desktop. psd
  # keeps the whole browser profile in /run/user/$UID and only flushes back on a
  # clean stop. Here that pinned 778M of tmpfs permanently, even with chrome
  # closed, out of 7.6G total. Spending a tenth of RAM to spare SSD writes is
  # the wrong way round on a host that OOMs, and the deferred flush loses the
  # profile on any ungraceful death.
  services.psd.enable = lib.mkForce false;

  # The share lives on the 4.5T USB Seagate, since the 119G root SSD cannot hold it.
  # nofail keeps boot going without the disk; RequiresMountsFor then keeps these
  # three from starting at all, instead of quietly writing into the bare
  # mountpoint on the SSD and filling it. No short device-timeout as on pc: USB
  # can take a while to enumerate, and timing out early would fail all three.
  fileSystems."/var/lib/copyparty" = {
    device = "/dev/disk/by-uuid/61088e9e-9818-4824-b5c0-c14d35a78ec5";
    fsType = "ext4";
    options = ["nofail"];
  };

  systemd.services = lib.genAttrs ["copyparty" "navidrome" "slskd"] (_: {
    unitConfig.RequiresMountsFor = ["/var/lib/copyparty"];
  });

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "24.05";
}
