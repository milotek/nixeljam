# Oracle Cloud aarch64 VPS — headless, deploy via nixos-anywhere.
# nixos-anywhere --flake .#vps --build-on remote -i ~/.ssh/id_ed25519 root@<ip>
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/user-password.nix
    ../../nixos/tailscale.nix
    ../../server-modules/ssh.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/caddy.nix
    ../../server-modules/game-relay.nix

    ./disko.nix
    ./hardware-configuration.nix
    ./variables.nix
    ./secrets
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = config.var.hostname;
    useDHCP = lib.mkDefault true;
  };

  time.timeZone = config.var.timeZone;
  i18n.defaultLocale = config.var.defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = config.var.extraLocale;
    LC_MONETARY = config.var.extraLocale;
    LC_TIME = config.var.extraLocale;
  };

  # The only host with a public IP, so the only one a scanner can reach. SSH
  # still works over tailscale0 (a trusted interface); break-glass is Oracle's
  # serial console.
  services.openssh.openFirewall = lib.mkForce false;

  environment.systemPackages = with pkgs; [wget curl git vim htop];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    # vps home modules (shell/git/nix-utils) use neither pkgs-unstable nor NUR,
    # so inputs is the only special arg they need.
    extraSpecialArgs = {inherit inputs;};
    users."${config.var.username}" = import ./home.nix;
  };

  system.stateVersion = "24.05";
}
