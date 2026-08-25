# GRUB with the minegrub world-selection theme: each boot entry is rendered as
# a Minecraft world save.
#
# Alternative to nixos/systemd-boot.nix - import exactly one of the two. The
# kernel and silent-boot settings below are deliberately identical to that
# module's, so switching between them only changes the bootloader.
{pkgs, ...}: {
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        devices = ["nodev"]; # EFI installs to the ESP, not to a disk's MBR
        useOSProber = true; # picks up the Windows install on the second NVMe
        configurationLimit = 8;

        # The theme is drawn at fixed pixel offsets against a 1920x1080
        # background, so anything else either letterboxes it or shrinks it into
        # the middle of the screen. "auto" is the fallback if the firmware
        # cannot give us that mode.
        gfxmodeEfi = "1920x1080,auto";

        minegrub-world-sel = {
          enable = true;
          customIcons = [
            {
              name = "nixos";
              lineTop = "nixeljam";
              lineBottom = "Creative Mode, Cheats, Version: 26.05";
              imgName = "nixos";
            }
            {
              name = "windows";
              lineTop = "Windows 11";
              lineBottom = "Survival Mode, No Cheats";
              imgName = "windows11";
            }
          ];
        };
      };
    };

    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # stylix would otherwise set its own splash image and colours on grub, which
  # is the one thing the minegrub theme needs sole ownership of.
  stylix.targets.grub.enable = false;

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
