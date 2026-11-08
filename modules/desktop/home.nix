# System (Desktop environment like stuff)
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    ./_home/clipboard
    ./_home/hypridle
    ./_home/hyprland
    ./_home/hyprlock
    ./_home/mime
    ./_home/power
    ./_home/scripts
    ./_home/swaync
    ./_home/tofi
    ./_home/udiskie
    ./_home/waybar
  ];
}
