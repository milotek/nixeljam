{
  config,
  lib,
  ...
}: {
  imports = [
    ./_hardware-configuration.nix
    ./_variables.nix
  ];

  # Sunshine screen capture needs the primary user in video + input groups.
  users.users.${config.var.username} = {
    extraGroups = ["video" "input"];
    linger = true;
  };

  # Once stable, run `sudo usbguard generate-policy` with all devices plugged in,
  # paste the output into rules below, then switch implicitPolicyTarget back to "block".
  services.usbguard.implicitPolicyTarget = lib.mkForce "allow";

  # Cleared - rules were from the laptop and don't match this machine's devices.
  # Regenerate with: sudo usbguard generate-policy
  services.usbguard.rules = "";

  services.timekpr.enable = true;

  # Root-owned RGB server with the i2c access OpenRGB needs, so the RTX 4080 FE logo light can be turned off.
  services.hardware.openrgb.enable = true;

  # Setcap wrapper for gsr-kms-server, so the replay buffer starts at login without a
  # polkit password prompt.
  programs.gpu-screen-recorder.enable = true;

  # console keymap is derived from the xkb layout (gb -> uk) by nixos/utils.nix
  # via console.useXkbConfig, so no per-host console.keyMap override is needed.

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech G502 X Plus]
    MatchName=Logitech G502 X PLUS
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES
  '';

  # Speakers are the AORUS monitors over HDMI. Nothing is plugged into the QuadCast's
  # headphone jack or the motherboard's optical out, but WirePlumber falls back to them
  # whenever the default output disappears, so audio silently goes nowhere.
  services.pipewire.wireplumber.extraConfig."50-hide-unused-outputs"."monitor.alsa.rules" = [
    {
      matches = [
        {"node.name" = "alsa_output.usb-HP__Inc_HyperX_QuadCast_S_4103-00.analog-stereo";}
        {"node.name" = "alsa_output.pci-0000_00_1f.3.iec958-stereo";}
      ];
      actions.update-props."node.disabled" = true;
    }
  ];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/454060ba-9c61-4e93-8e77-e54ee4bfe1e2";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=5s" "x-gvfs-show" "x-gvfs-name=Storage"];
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/1552703a-2078-44ca-b6d1-e12fc3891e28";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=5s" "x-gvfs-show" "x-gvfs-name=SSD"];
  };

  home-manager.users."${config.var.username}" = import ./_home.nix;

  # Don't touch this
  system.stateVersion = "24.05";
}
