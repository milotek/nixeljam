{
  config,
  lib,
  ...
}: {
  imports = [
    ./_hardware-configuration.nix
    ./_variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./_home.nix;

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
  users.users.${config.var.username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEX5YUtG4lyBcGJPe2ze+MJZ6Lv/L8evoCR3ASw2fFVo milo@milotek.dev"
    ];
    extraGroups = ["ydotool"];
  };

  programs.ydotool.enable = true;
  programs.thunar.enable = true;
  programs.gpu-screen-recorder.enable = true;
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

  stylix = {
    image = lib.mkForce ./wallpaper.jpg;
    base16Scheme = lib.mkForce {
      base00 = "1e1e2e"; # Default Background
      base01 = "181825"; # Lighter Background (Used for status bars, line number and folding marks)
      base02 = "313244"; # Selection Background
      base03 = "45475a"; # Comments, Invisibles, Line Highlighting
      base04 = "585b70"; # Dark Foreground (Used for status bars)
      base05 = "cdd6f4"; # Default Foreground, Caret, Delimiters, Operators
      base06 = "f5c2e7"; # Light Foreground (Not often used)
      base07 = "b4befe"; # Light Background (Not often used)
      base08 = "f38ba8"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      base09 = "fab387"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      base0A = "f9e2af"; # Classes, Markup Bold, Search Text Background
      base0B = "a6e3a1"; # Strings, Inherited Class, Markup Code, Diff Inserted
      base0C = "94e2d5"; # Support, Regular Expressions, Escape Characters, Markup Quotes
      base0D = "ffbdbd"; # Functions, Methods, Attribute IDs, Headings, Accent color
      base0E = "cba4f7"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      base0F = "f2cdcd"; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    };
  };

  # Don't touch this
  system.stateVersion = "24.05";
}
