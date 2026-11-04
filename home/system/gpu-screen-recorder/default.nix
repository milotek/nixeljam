{
  pkgs,
  config,
  ...
}: let
  clipsDir = "${config.home.homeDirectory}/Videos/Recordings/Clips";
  monitor = "HDMI-A-1"; # Not "focused": a persistent replay buffer can't follow focus on Wayland
  replaySeconds = 30;

  onSave = pkgs.writeShellScript "gsr-clip-saved" ''
    ${pkgs.libnotify}/bin/notify-send -a "Clips" -i video-x-generic \
      "Clip saved" "$(${pkgs.coreutils}/bin/basename "$1")"
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
      ExecStart = ''
        ${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder \
          -w ${monitor} \
          -f 60 \
          -q very_high \
          -c mp4 \
          -a "default_output|default_input" \
          -r ${toString replaySeconds} \
          -replay-storage ram \
          -sc ${onSave} \
          -ro ${clipsDir}
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
