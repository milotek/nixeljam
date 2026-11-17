# Bluetooth configuration for NixOS
{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.persistence."/persist".directories = ["/var/lib/bluetooth"]; # Bluetooth connections
  };
}
