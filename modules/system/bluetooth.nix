# Bluetooth configuration for NixOS
{aspects, ...}: {
  flake.modules.nixos.bluetooth = {
    imports = [aspects.common];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.persistence."/persist".directories = ["/var/lib/bluetooth"]; # Bluetooth connections
  };
}
