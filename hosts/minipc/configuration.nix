{config, ...}: {
  imports = [
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/tuigreet.nix
    ../../nixos/sway.nix
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/ssh.nix
    ../../nixos/ydotool.nix
    ../../nixos/reverse-tunnel.nix

    # Self-hosted services — add more from server-modules/ as needed
    ../../server-modules/adguardhome.nix
    ../../server-modules/fail2ban.nix

    ./hardware-configuration.nix
    ./variables.nix
    ./secrets
  ];

  # Reachable via the VPS at:  ssh -p 2223 <user>@tek.rip
  # Dials out to the VPS and exposes this host's sshd on the VPS's public
  # port 2223. Uses the primary milo@milotek.dev key (stored as the
  # reverse-tunnel-key system secret), which the VPS already authorizes.
  custom.reverseTunnel = {
    enable = true;
    sopsFile = ./secrets/system-secrets.yaml;
    forwards = [
      {
        remoteBind = "*";
        remotePort = 2223;
        localPort = 22;
      }
    ];
  };

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "24.05";
}
