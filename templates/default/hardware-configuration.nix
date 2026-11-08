# CHANGEME: replace with /etc/nixos/hardware-configuration.nix from your install
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
}
