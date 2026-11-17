# Noctalia is the desktop shell: bar, launcher, notifications, lock screen, OSD and wallpaper
{
  aspects,
  inputs,
  ...
}: {
  flake.modules.nixos.noctalia.imports = [aspects.home-manager];
  flake.modules.nixos.noctalia.home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    (
      {pkgs, ...}: {
        programs.noctalia-shell = {
          enable = true;
          package = pkgs.noctalia-shell;
          systemd.enable = true;
          settings.appLauncher.terminalCommand = "${pkgs.ghostty}/bin/ghostty -e";

          plugins.states.screen-recorder = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          pluginSettings.screen-recorder = {
            directory = "~/Videos/Recordings";
            replayEnabled = true;
            replayDuration = "30";
            hideInactive = true;
          };
          settings.bar.widgets.right = [
            {id = "plugin:screen-recorder";}
            {id = "Tray";}
            {id = "NotificationHistory";}
            {id = "Battery";}
            {id = "Volume";}
            {id = "Brightness";}
            {id = "ControlCenter";}
          ];
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
  flake.modules.nixos.noctalia.programs.gpu-screen-recorder.enable = true;
}
