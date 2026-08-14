# Browser-accessible remote desktop for this Hyprland (wlroots) session.
#
# wayvnc mirrors the live Wayland session as a VNC server on localhost:5900,
# and websockify serves the noVNC web client on localhost:6080, bridging the
# browser's WebSocket to that VNC port. The host's reverse tunnel
# (nixos/reverse-tunnel.nix) forwards 6080 up to the VPS, where caddy fronts it
# at https://remote.<host>.<domain>.
#
# Nothing here listens beyond 127.0.0.1, so the only public entry point is
# caddy on the VPS (TLS + basic auth). wayvnc attaches to the running
# compositor, so remote access only works while the user is logged into
# Hyprland - at the greeter there is no session to mirror.
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
      ExecStart = "${websockify}/bin/websockify --web=${novncRoot} 127.0.0.1:${toString webPort} 127.0.0.1:${toString vncPort}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
