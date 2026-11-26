{
  config,
  lib,
  ...
}: {
  imports = [
    ./_hardware-configuration.nix
  ];

  home-manager.users.${config.nixeljam.username} = import ./_home.nix;

  hardware.nvidia = {
    powerManagement.finegrained = lib.mkForce false;
    prime.offload = {
      enable = lib.mkForce false;
      enableOffloadCmd = lib.mkForce false;
    };
  };

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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.${config.nixeljam.username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev"
    ];
    extraGroups = ["ydotool"];
  };

  programs.ydotool.enable = true;
  programs.thunar.enable = true;
  services.hardware.openrgb.enable = true;

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech G502 X Plus]
    MatchName=Logitech G502 X PLUS
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES
  '';

  services.pipewire.wireplumber.extraConfig."50-hide-unused-outputs"."monitor.alsa.rules" = [
    {
      matches = [
        {"node.name" = "alsa_output.usb-HP__Inc_HyperX_QuadCast_S_4103-00.analog-stereo";}
        {"node.name" = "alsa_output.pci-0000_00_1f.3.iec958-stereo";}
      ];
      actions.update-props."node.disabled" = true;
    }
  ];

  # Don't touch this
  system.stateVersion = "24.05";
}
