# Nvidia configuration for NixOS with Wayland and Hyprland support
# Import this module only if you have an Nvidia GPU
{
  flake.modules.nixos.nvidia = {
    pkgs,
    config,
    ...
  }: let
    nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.production;
  in {
    services.xserver.videoDrivers = ["nvidia"];

    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Improves resume after sleep
    ];

    boot.blacklistedKernelModules = ["nouveau"];

    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
      NVD_BACKEND = "direct";
    };

    nixpkgs.config = {
      nvidia.acceptLicense = true;
    };

    hardware = {
      nvidia = {
        open = false; # Proprietary driver for better performance
        nvidiaSettings = true;
        powerManagement = {
          enable = true;
          finegrained = false;
        };
        modesetting.enable = true;
        package = nvidiaDriverChannel;
        forceFullCompositionPipeline = true;
      };

      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          libva-vdpau-driver
          libvdpau-va-gl
          mesa
          egl-wayland
          vulkan-loader
          vulkan-validation-layers
          libva
        ];
      };
    };

    # Nix cache for CUDA
    nix.settings = {
      substituters = ["https://cuda-maintainers.cachix.org"];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
      libva-utils
    ];

    hardware.nvidia-container-toolkit.enable = false;
  };
}
