# HyprPolkitAgent is a simple polkit agent for wayland compositors
{aspects, ...}: {
  flake.modules.nixos.desktop.imports = [aspects.home-manager];
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    {
      services.hyprpolkitagent.enable = true;
    }
  ];
}
