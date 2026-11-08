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

        # Marks this version as already set up: no first-run wizard or changelog popup
        systemd.user.tmpfiles.rules = [
          "C %h/.cache/noctalia/shell-state.json - - - - ${(pkgs.formats.json {}).generate "shell-state.json" {
            changelogState.lastSeenVersion = "v${pkgs.noctalia-shell.version}";
          }}"
        ];
      }
    )
  ];
}
