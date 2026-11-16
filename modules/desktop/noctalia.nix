# Noctalia is the desktop shell: bar, launcher, notifications, lock screen, OSD and wallpaper
# Colors, fonts and wallpaper come from stylix (its noctalia-shell target)
{inputs, ...}: {
  flake.modules.nixos.noctalia.programs.gpu-screen-recorder.enable = true;
  flake.modules.nixos.noctalia.home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    (
      {
        lib,
        pkgs,
        ...
      }: {
        programs.noctalia-shell = {
          enable = true;
          package = pkgs.noctalia-shell;
          systemd.enable = true;
          settings.appLauncher.terminalCommand = "${pkgs.ghostty}/bin/ghostty -e";

          plugins = {
            version = 2;
            states.screen-recorder = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          pluginSettings.screen-recorder = {
            videoSource = lib.mkDefault "screen";
            directory = "~/Videos/Recordings";
            replayEnabled = true;
            replayDuration = "30";
            hideInactive = true;
          };
          # noctalia replaces this list instead of merging it, so it repeats the defaults around the recorder
          settings.bar.widgets.right = map (id: {inherit id;}) ["plugin:screen-recorder" "Tray" "NotificationHistory" "Battery" "Volume" "Brightness" "ControlCenter"];
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
