# HyprPolkitAgent is a simple polkit agent for wayland compositors
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    {
      services.hyprpolkitagent.enable = true;
    }
  ];
}
