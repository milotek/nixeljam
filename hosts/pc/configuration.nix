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

  # Reachable over the tailnet: ssh and the noVNC desktop on :6080.

  # Sunshine screen capture needs the primary user in video + input groups.
  users.users.${config.var.username}.extraGroups = ["video" "input"];

  # USBGuard: currently set to allow all devices.
  # Once stable, run `sudo usbguard generate-policy` with all devices plugged in,
  # paste the output into rules below, then switch implicitPolicyTarget back to "block".
  services.usbguard.implicitPolicyTarget = lib.mkForce "allow";

  # Cleared — rules were from the laptop and don't match this machine's devices.
  # Regenerate with: sudo usbguard generate-policy
  services.usbguard.rules = "";

  # console keymap is derived from the xkb layout (gb -> uk) by nixos/utils.nix
  # via console.useXkbConfig, so no per-host console.keyMap override is needed.

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
