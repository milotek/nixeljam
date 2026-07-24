# ShadowPlay-like instant replay via gpu-screen-recorder.
#
# An always-on replay daemon continuously buffers the last N seconds of the
# primary monitor in RAM using NVENC. Pressing the save key (see
# home/system/hyprland/bindings.nix) sends SIGUSR1 to flush that buffer to a
# clip file in ~/Videos/Recordings/Clips/.
{
  pkgs,
  config,
  ...
}: let
  clipsDir = "${config.home.homeDirectory}/Videos/Recordings/Clips";
  replaySeconds = 30;

  # Runs after each save with the saved file path as $1; gives ShadowPlay-style feedback.
  onSave = pkgs.writeShellScript "gsr-clip-saved" ''
    ${pkgs.libnotify}/bin/notify-send -a "Clips" -i video-x-generic \
      "Clip saved" "$(${pkgs.coreutils}/bin/basename "$1")"
  '';

  # Resolve the primary monitor (the one at 0,0) at start, then record it.
  run = pkgs.writeShellScript "gsr-replay" ''
    mon=$(/run/current-system/sw/bin/hyprctl monitors -j \
      | ${pkgs.jq}/bin/jq -r 'first(.[] | select(.x==0 and .y==0) | .name) // "screen"')
    exec /run/current-system/sw/bin/gpu-screen-recorder \
      -w "$mon" \
      -f 60 \
      -q very_high \
      -c mp4 \
      -a "default_output|default_input" \
      -r ${toString replaySeconds} \
      -replay-storage ram \
      -sc ${onSave} \
      -o ${clipsDir}
  '';
in {
  home.packages = [pkgs.gpu-screen-recorder];

  systemd.user.services.gpu-screen-recorder-replay = {
    Unit = {
      Description = "GPU Screen Recorder instant replay buffer (ShadowPlay-like)";
      After = ["graphical-session.target" "pipewire.service"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${clipsDir}";
      ExecStart = "${run}";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
