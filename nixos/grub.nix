# Kernel and boot settings mirror nixos/systemd-boot.nix; keep them in sync.
{pkgs, ...}: {
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        devices = ["nodev"];
        useOSProber = true;
        configurationLimit = 8;

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

  stylix.targets.grub.enable = false;

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
