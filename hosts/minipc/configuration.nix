{config, ...}: {
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

    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Reachable over the tailnet; the VPS's caddy proxies copyparty, navidrome,
  # slskd and home-assistant from there over TLS.

  sops = {
    defaultSopsFile = ./secrets/system-secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "24.05";
}
