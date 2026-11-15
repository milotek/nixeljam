# Instant replay and screen recording, through noctalia's screen-recorder plugin (gpu-screen-recorder)
# Mod+Print: once saves the last 30s, twice starts/stops a recording
{
  flake.modules.nixos.replay = {
    programs.gpu-screen-recorder.enable = true;

    home-manager.sharedModules = [
      (
        {
          lib,
          pkgs,
          ...
        }: let
          plugins = pkgs.fetchFromGitHub {
            owner = "noctalia-dev";
            repo = "noctalia-plugins";
            rev = "ea21cb63d063075bc0acd72d8b946ce2c5eef00d";
            hash = "sha256-M+7SLW+wI3KvDMj8dSrW/uUmpPiYhsXA2jpbbgL5imk=";
          };
          recorder = cmd: "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call plugin:screen-recorder ${cmd}";
        in {
          xdg.configFile."noctalia/plugins/screen-recorder" = {
            source = "${plugins}/screen-recorder";
            recursive = true;
          };

          programs.noctalia-shell = {
            plugins = {
              version = 2;
              sources = [];
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

          # The plugin never starts the replay buffer on its own; startReplay is a no-op once it runs
          systemd.user.services.replay = {
            Unit = {
              Description = "Start noctalia's replay buffer";
              After = ["noctalia-shell.service"];
              PartOf = ["graphical-session.target"];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.writeShellScript "replay-start" ''
                for _ in 1 2 3 4 5 6; do
                  sleep 5
                  ${recorder "startReplay"} || true
                done
              ''}";
            };
            Install.WantedBy = ["graphical-session.target"];
          };

          xdg.configFile."niri/replay.kdl".text = ''
            binds {
                Mod+Print { spawn "niri-tap" "replay" "${recorder "saveReplay"}" "${recorder "toggle"}"; }
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
