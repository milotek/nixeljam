# Audio configuration for NixOS using PipeWire
{
  flake.modules.nixos.audio = {pkgs, ...}: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    security.rtkit.enable = true;

    environment.systemPackages = [pkgs.alsa-utils];
  };
}
