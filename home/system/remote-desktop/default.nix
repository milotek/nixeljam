# Browser-accessible remote desktop for this Hyprland (wlroots) session.
#
# wayvnc mirrors the live Wayland session as a VNC server, and websockify
# serves the noVNC web client on 6080, bridging the browser's WebSocket to that
# VNC port. Reachable at http://<this host's tailnet ip>:6080 from any tailnet
# device; the firewall trusts tailscale0 only, so nothing is exposed publicly.
#
# VNC itself is unauthenticated, so the tailnet IS the authentication.
# wayvnc attaches to the running compositor, so remote access only works while
# the user is logged into Hyprland - at the greeter there is no session to mirror.
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
      ExecStart = "${websockify}/bin/websockify --web=${novncRoot} 0.0.0.0:${toString webPort} 127.0.0.1:${toString vncPort}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
