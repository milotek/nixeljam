{config, lib, ...}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/nvidia.nix # Remove this line if you don't have an Nvidia GPU
    ../../nixos/audio.nix
    ../../nixos/bluetooth.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/tuigreet.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/hyprland.nix
    ../../nixos/usbguard.nix
    ../../home/programs/helium/system.nix # I hate browser's configuration..
    ../../nixos/gaming.nix
    ../../nixos/ssh.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # USBGuard: currently set to allow all devices.
  # Once stable, run `sudo usbguard generate-policy` with all devices plugged in,
  # paste the output into rules below, then switch implicitPolicyTarget back to "block".
  services.usbguard.implicitPolicyTarget = lib.mkForce "allow";

  # Cleared — rules were from the laptop and don't match this machine's devices.
  # Regenerate with: sudo usbguard generate-policy
  services.usbguard.rules = "";

  # utils.nix sets console.keyMap = keyboardLayout ("gb"), but loadkeys needs "uk"
  console.keyMap = lib.mkForce "uk";

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech G502 X Plus]
    MatchName=Logitech G502 X PLUS
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES
  '';

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
