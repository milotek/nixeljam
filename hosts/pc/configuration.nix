{
  config,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/nvidia.nix # Remove this line if you don't have an Nvidia GPU
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/grub.nix
    ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/hyprland.nix
    ../../nixos/ydotool.nix
    ../../nixos/usbguard.nix
    ../../nixos/gaming.nix
    ../../nixos/docker.nix
    ../../nixos/ollama.nix

    ../../nixos/tailscale.nix
    ../../server-modules/ssh.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # Sunshine screen capture needs video + input.
  users.users.${config.var.username}.extraGroups = ["video" "input"];

  # Keep "allow" until rules are generated, or "block" with empty rules blocks every USB device.
  services.usbguard.implicitPolicyTarget = lib.mkForce "allow";
  services.usbguard.rules = "";

  services.timekpr.enable = true;

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech G502 X Plus]
    MatchName=Logitech G502 X PLUS
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES
  '';

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/454060ba-9c61-4e93-8e77-e54ee4bfe1e2";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=5s" "x-gvfs-show" "x-gvfs-name=Storage"];
  };

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
