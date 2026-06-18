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
    ../../nixos/ssh.nix
    ../../server-modules/fail2ban.nix
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

  # ssh.nix carries the upstream template's key — replace with ours.
  users.users."${config.var.username}".openssh.authorizedKeys.keys = lib.mkForce [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfO5Sf5oDj52b+nKqi5EbW0ZxsfBpMPIZPxG6pYgtmf milo@milotek.dev"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev"
  ];
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

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
