# Oracle Cloud aarch64 VPS - headless, deploy via nixos-anywhere.
# nixos-anywhere --flake .#vps --build-on remote -i ~/.ssh/id_ed25519 root@<ip>
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_disko.nix
    ./_hardware-configuration.nix
    ./_variables.nix
    ./_secrets
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

  home-manager.users."${config.var.username}" = import ./_home.nix;

  system.stateVersion = "24.05";
}
