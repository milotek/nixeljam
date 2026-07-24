# Oracle Cloud aarch64 VPS — headless, deploy via nixos-anywhere.
# nixos-anywhere --flake .#vps --build-on remote -i ~/.ssh/github root@<ip>
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
    ../../nixos/ssh.nix
    ../../server-modules/fail2ban.nix
    ../../server-modules/caddy.nix
    ../../server-modules/copyparty.nix

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

  # Reverse-tunnel key from the PC: forwarding only. It may bind the public SSH
  # port (2222) and the private noVNC port (localhost:6080, fronted by caddy).
  users.users."${config.var.username}".openssh.authorizedKeys.keys = [
    ''restrict,port-forwarding,permitlisten="*:2222",permitlisten="localhost:6080" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkXUvwdZwGo6J6Qg6ag/0UelloJD+wx25zQ8kksxGAY pc-tunnel''
  ];

  # Let the tunnels bind a public port, and open them.
  services.openssh.settings.GatewayPorts = "clientspecified";
  networking.firewall.allowedTCPPorts = [2222 2223];

  environment.systemPackages = with pkgs; [wget curl git vim htop];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs;
      pkgs-stable = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
      # nur-anotherhadi only targets x86_64; VPS home modules don't use it.
      pkgs-nur-hadi = {};
    };
    users."${config.var.username}" = import ./home.nix;
  };

  system.stateVersion = "24.05";
}
