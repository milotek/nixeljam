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
    ../../nixos/ssh.nix
    ../../nixos/ydotool.nix
    ../../nixos/reverse-tunnel.nix

    # Self-hosted services — add more from server-modules/ as needed
    ../../server-modules/adguardhome.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/copyparty.nix
    ../../server-modules/navidrome.nix

    ./hardware-configuration.nix
    ./variables.nix
    ./secrets
  ];

  # Reachable via the VPS at:  ssh -p 2223 <user>@tek.rip
  custom.reverseTunnel = {
    enable = true;
    sopsFile = ./secrets/system-secrets.yaml;
    forwards = [
      {
        remoteBind = "*";
        remotePort = 2223;
        localPort = 22;
      }
      {
        remoteBind = "localhost";
        remotePort = 3923;
        localPort = 3923;
      }
      {
        remoteBind = "localhost";
        remotePort = 4533;
        localPort = 4533;
      }
    ];
  };

  sops = {
    defaultSopsFile = ./secrets/system-secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "24.05";
}
