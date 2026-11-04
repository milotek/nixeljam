# NixOS under WSL2. Rebuild from inside the distro with:
#   sudo nixos-rebuild switch --flake .#wsl
#
# Windows owns the kernel, init and networking here, so this host skips
# nixos/utils.nix (which pulls in xserver, portals and power management) and
# declares the handful of settings it actually needs directly.
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/home-manager.nix
    ../../nixos/docker.nix

    ./variables.nix
  ];

  wsl = {
    enable = true;
    defaultUser = config.var.username;
    # Keeps `wslpath`, `clip.exe` and friends resolvable from the NixOS side.
    interop.includePath = true;
  };

  networking.hostName = config.var.hostname;

  time.timeZone = config.var.timeZone;
  i18n.defaultLocale = config.var.defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = config.var.extraLocale;
    LC_MONETARY = config.var.extraLocale;
    LC_TIME = config.var.extraLocale;
  };

  environment.systemPackages = with pkgs; [wget curl git vim htop];

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "26.05";
}
