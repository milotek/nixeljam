# Instant replay and screen recording, through noctalia's screen-recorder plugin (gpu-screen-recorder)
# Holding Print saves the last 30s, holding Mod+Print starts/stops a recording
{
  flake.modules.nixos.replay = {
    programs.gpu-screen-recorder.enable = true;

    # Hold Print for F13 (for keyboards without F13)
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings.main.sysrq = "timeout(sysrq, 300, f13)";
      };
    };

    home-manager.sharedModules = [
      (
        {
          lib,
          pkgs,
          ...
        }: let
          noctalia = "${pkgs.noctalia-shell}/bin/noctalia-shell";
          recorder = cmd: "${noctalia} ipc call plugin:screen-recorder ${cmd}";
        in {
          programs.noctalia-shell = {
            plugins = {
              version = 2;
              # noctalia downloads enabled plugins that aren't on disk yet
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
            # noctalia's default right side, with the recorder in front
            settings.bar.widgets.right = map (id: {inherit id;}) ["plugin:screen-recorder" "Tray" "NotificationHistory" "Battery" "Volume" "Brightness" "ControlCenter"];
          };

          # The plugin never starts the replay buffer on its own, and it loads a while after noctalia starts
          systemd.user.services.replay = {
            Unit.After = ["noctalia-shell.service"];
            Service.ExecStart = pkgs.writeShellScript "replay" ''
              until [[ $(${noctalia} ipc show) == *"target plugin:screen-recorder"* ]]; do sleep 1; done
              ${recorder "startReplay"}
            '';
            Install.WantedBy = ["graphical-session.target"];
          };

          xdg.configFile."niri/replay.kdl".text = ''
            binds {
                F13 { spawn-sh "${recorder "saveReplay"}"; }
                Mod+F13 { spawn-sh "${recorder "toggle"}"; }
            }
          '';
          xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
            include "./replay.kdl"
          '';
        }
      )
    ];
  };
}
