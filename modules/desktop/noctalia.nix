# Noctalia is the desktop shell: bar, launcher, notifications, lock screen, OSD and wallpaper
# Colors, fonts and wallpaper come from stylix (its noctalia-shell target)
{inputs, ...}: {
  flake.modules.nixos.noctalia.home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    (
      {pkgs, ...}: {
        programs.noctalia-shell = {
          enable = true;
          package = pkgs.noctalia-shell;
          systemd.enable = true;
          settings.appLauncher.terminalCommand = "${pkgs.ghostty}/bin/ghostty -e";
        };
      }
    )
  ];
}
