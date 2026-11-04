{
  pkgs,
  ...
}: let
  vncPort = 5900;
  webPort = 6080;
  novncRoot = "${pkgs.novnc}/share/webapps/novnc";
  websockify = pkgs.python3Packages.websockify;
in {
  home.packages = [pkgs.wayvnc websockify];

  systemd.user.services.wayvnc = {
    Unit = {
      Description = "wayvnc - VNC server for the Wayland session";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wayvnc}/bin/wayvnc 127.0.0.1 ${toString vncPort}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.novnc = {
    Unit = {
      Description = "noVNC web client (websockify) fronting wayvnc";
      After = ["wayvnc.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      # VNC is unauthenticated: 0.0.0.0 is only safe while the firewall trusts tailscale0 alone.
      ExecStart = "${websockify}/bin/websockify --web=${novncRoot} 0.0.0.0:${toString webPort} 127.0.0.1:${toString vncPort}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
