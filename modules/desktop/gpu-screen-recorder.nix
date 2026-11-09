# ShadowPlay-like instant replay via gpu-screen-recorder.
#
# An always-on replay daemon continuously buffers the last N seconds of the
# primary monitor (HDMI-A-1) in RAM using NVENC. Pressing Super+Print (bound
# below) sends SIGUSR1 to flush that buffer to a clip file in
# ~/Videos/Recordings/Clips/.
{
  flake.modules.nixos.gpu-screen-recorder.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: let
        clipsDir = "${config.home.homeDirectory}/Videos/Recordings/Clips";
        monitor = "HDMI-A-1"; # Primary AORUS FI27Q-X; Wayland can't follow focus in a persistent buffer
        replaySeconds = 30;

        # Runs after each save with the saved file path as $1; gives ShadowPlay-style feedback.
        onSave = pkgs.writeShellScript "gsr-clip-saved" ''
          ${pkgs.libnotify}/bin/notify-send -a "Clips" -i video-x-generic \
            "Clip saved" "$(${pkgs.coreutils}/bin/basename "$1")"
        '';
      in {
        home.packages = [pkgs.gpu-screen-recorder];

        # niri has no hold binds, so the save key is Super+Print instead of holding Print
        xdg.configFile."niri/replay.kdl".text = ''
          binds {
              Mod+Print { spawn "systemctl" "--user" "kill" "-s" "SIGUSR1" "--kill-whom=main" "gpu-screen-recorder-replay.service"; }
          }
        '';
        xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
          include "./replay.kdl"
        '';

        systemd.user.services.gpu-screen-recorder-replay = {
          Unit = {
            Description = "GPU Screen Recorder instant replay buffer (ShadowPlay-like)";
            After = ["graphical-session.target" "pipewire.service"];
            PartOf = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${clipsDir}";
            ExecStart = ''
              ${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder \
                -w ${monitor} \
                -f 60 \
                -q very_high \
                -c mp4 \
                -a "app-inverse:gpu-screen-recorder|default_input" \
                -ac aac \
                -r ${toString replaySeconds} \
                -replay-storage ram \
                -sc ${onSave} \
                -o ${clipsDir}
            '';
            Restart = "on-failure";
            RestartSec = 5;
          };

          Install.WantedBy = ["graphical-session.target"];
        };
      }
    )
  ];
}
