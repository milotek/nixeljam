# Bluetooth configuration for NixOS
{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
