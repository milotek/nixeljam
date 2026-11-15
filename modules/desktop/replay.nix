# Instant replay and screen recording, through noctalia's screen-recorder plugin (gpu-screen-recorder)
# Print twice saves the last 30s, Mod+Print twice starts/stops a recording
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
          noctalia = "${pkgs.noctalia-shell}/bin/noctalia-shell";
          recorder = cmd: "${noctalia} ipc call plugin:screen-recorder ${cmd}";
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
            # noctalia's default right side, with the recorder in front
            settings.bar.widgets.right = map (id: {inherit id;}) ["plugin:screen-recorder" "Tray" "NotificationHistory" "Battery" "Volume" "Brightness" "ControlCenter"];
          };

          # The plugin never starts the replay buffer on its own, and it loads a while after noctalia starts
          systemd.user.services.replay = {
            Unit = {
              Description = "Start noctalia's replay buffer";
              After = ["noctalia-shell.service"];
              PartOf = ["graphical-session.target"];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.writeShellScript "replay-start" ''
                until ${noctalia} ipc show | ${pkgs.gnugrep}/bin/grep -q "target plugin:screen-recorder"; do sleep 1; done
                ${recorder "startReplay"}
              ''}";
            };
            Install.WantedBy = ["graphical-session.target"];
          };

          xdg.configFile."niri/replay.kdl".text = ''
            binds {
                Print { spawn "niri-tap" "print" "niri msg action screenshot-screen" "${recorder "saveReplay"}"; }
                Mod+Print { spawn "niri-tap" "mod-print" "niri msg action screenshot" "${recorder "toggle"}"; }
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
