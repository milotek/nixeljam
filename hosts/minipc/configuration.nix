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

    # Self-hosted services — add more from server-modules/ as needed
    ../../server-modules/adguardhome.nix
    ../../server-modules/fail2ban.nix

    ./hardware-configuration.nix
    ./variables.nix
    ./secrets
  ];

  services.tailscale.enable = true;

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "24.05";
}
