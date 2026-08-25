# spotify-mirror — make Navidrome listening show up in Spotify's own stats.
#
# WHY IT IS SHAPED LIKE THIS
#
# Spotify has no ingest API. Nothing accepts "I listened to this", so no play
# from Navidrome can be injected into your history, and stats.fm — which only
# reads Spotify's API — inherits that limitation exactly. The only listening
# that ever counts is playback that genuinely happened on a Spotify client.
#
# The Web API can start playback on a device, but only for Premium accounts. On
# a free account the remaining lever is the desktop client, which since
# September 2025 does on-demand playback of any track. So: run the real desktop
# client here, headless and muted, and drive it over MPRIS every time Navidrome
# starts a song. Those are real streams. They count for stats.fm, for Wrapped,
# for the recommendation algorithm, and they pay the artist.
#
# THINGS TO KNOW BEFORE ENABLING
#
#   - Free accounts get an undocumented daily on-demand allowance. tunedeck
#     keeps its own ledger and stops early, so the mirror cannot quietly eat the
#     quota you wanted for real listening.
#   - One account plays on one device at a time. The mirror reads /me/player
#     first and stands down whenever you are playing somewhere else, so it never
#     yanks playback out from under you.
#   - Free playback is interrupted by ads. They play into the null sink and cost
#     a little budget; nothing breaks.
#   - This is automated playback of audio nobody hears, which is the shape
#     Spotify's artificial-streaming detection looks for. You are genuinely
#     listening, just on a different player — but the account risk is real and
#     it is yours.
#
# SETUP. No Spotify app registration needed by default — see tunedeck.nix for
# where the credentials come from. After `nixos-rebuild switch`:
#
#   1. open the console (below) and log the Spotify window in, once
#   2. sudo -u milotek tunedeck-auth      authorise the API side, once
#   3. systemctl restart tunedeck-mirror
#
# Watch it: sudo -u milotek tunedeck-auth status, journalctl -fu tunedeck-mirror
{
  config,
  lib,
  pkgs,
  ...
}: let
  tunedeck = import ../pkgs/tunedeck/package.nix {inherit pkgs;};
  user = config.var.username;
  console = config.var.tunedeck.console;

  # Its own HOME, so the headless client keeps a separate profile instead of
  # fighting the desktop Spotify over ~/.config/spotify.
  spotifyHome = "/var/lib/tunedeck/spotify-home";

  displayNum = "97";
  display = ":${displayNum}";
  vncPort = 5901;
  webPort = 6081;

  # MPRIS lives on the session bus, so these units have to join the user's
  # session rather than run in isolation.
  #
  # The UID is resolved at runtime, not in the unit. systemd's %U looks like the
  # obvious answer and is a trap: in a *system* unit it expands to the UID of the
  # service manager (0), not of User=. That silently pointed everything at
  # /run/user/0, so the session bus was unreachable and MPRIS could never have
  # worked — the mirror would have run forever without ever playing anything.
  # users.users.<name>.uid is null here, so there is nothing static to read.
  #
  # Also waits for the bus socket: linger brings the user manager up at boot,
  # but not necessarily before this unit starts.
  inSession = name: cmd:
    pkgs.writeShellScript "tunedeck-${name}-session" ''
      export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      bus="$XDG_RUNTIME_DIR/bus"
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"
      export PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native"
      export PULSE_SINK=tunedeck-null
      export DISPLAY=${display}

      for _ in $(${pkgs.coreutils}/bin/seq 1 150); do
        [ -S "$bus" ] && break
        sleep 0.2
      done
      [ -S "$bus" ] || echo "warning: no session bus at $bus — MPRIS will not work" >&2

      exec ${cmd}
    '';

  # Anything you want to look at on the headless display, from the phone.
  tunedeckBrowser = pkgs.writeShellScriptBin "tunedeck-browser" ''
    # A browser on the mirror's display, for the Spotify developer dashboard and
    # anything else that will not behave on a phone screen.
    exec env DISPLAY=${display} ${pkgs.google-chrome}/bin/google-chrome-stable \
      --user-data-dir=/var/lib/tunedeck/browser \
      --no-first-run --no-default-browser-check "$@"
  '';

  tunedeckConsole = pkgs.writeShellScriptBin "tunedeck-console" ''
    ip="$(${pkgs.tailscale}/bin/tailscale ip -4 2>/dev/null | head -1)"
    echo "console:  http://''${ip:-<tailnet-ip>}:${toString webPort}/vnc.html"
    echo
    echo "That is the headless display (${display}) — the Spotify window lives"
    echo "there. Open it from any tailnet device, including your phone."
    echo "  tunedeck-browser <url>   put a browser on the same display"
    ${pkgs.systemd}/bin/systemctl status tunedeck-vnc tunedeck-novnc --no-pager -n 0 || true
  '';
in {
  imports = [./tunedeck.nix];

  environment.systemPackages =
    [pkgs.playerctl]
    ++ lib.optionals console [tunedeckBrowser tunedeckConsole];

  # A sink that goes nowhere. The mirror exists to be counted, not heard, and
  # routing it to the real output would make the box play music at itself.
  services.pipewire.extraConfig.pipewire."10-tunedeck-null" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "tunedeck-null";
          "node.description" = "tunedeck (silent mirror sink)";
          "media.class" = "Audio/Sink";
          "audio.position" = ["FL" "FR"];
        };
      }
    ];
  };

  # The session bus has to exist even when nobody is sitting at the greeter.
  users.users.${user}.linger = true;

  systemd.tmpfiles.rules = [
    "d ${spotifyHome} 0700 ${user} users - -"
    "d /var/lib/tunedeck/browser 0700 ${user} users - -"
  ];

  # A real X server rather than xvfb-run, because x11vnc has to be able to
  # attach to it by name. xvfb-run picks its own display and auth file, which
  # nothing else can find.
  #
  # Everything that draws on this display is PartOf= it, so an Xvfb restart
  # cycles them cleanly instead of leaving each one to crash against a dead
  # socket and recover on its own timer.
  systemd.services.tunedeck-xvfb = {
    description = "Xvfb ${display} — the headless display the mirror lives on";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = user;
      # -nolisten tcp keeps it to the local socket; the only reachability is
      # through x11vnc below, which is itself bound to localhost.
      ExecStart = "${pkgs.xorg-server}/bin/Xvfb ${display} -screen 0 1280x800x24 -nolisten tcp";
      # Type=simple marks the unit active the moment Xvfb forks, but the socket
      # takes a beat longer — so openbox and x11vnc would start, fail to open
      # the display, and only recover on their restart timer. That left a failed
      # unit on every boot and made switch-to-configuration exit 4. Units
      # ordered After= this one wait for ExecStartPost, so block here instead.
      ExecStartPost = "${pkgs.bash}/bin/bash -c 'for _ in $(seq 1 100); do [ -S /tmp/.X11-unix/X${displayNum} ] && exit 0; sleep 0.1; done; exit 1'";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  # Without a window manager, Spotify's login dialogs come up unmanaged and
  # cannot be focused or moved — which makes the one thing the console exists
  # for impossible.
  systemd.services.tunedeck-wm = {
    description = "openbox on ${display}";
    after = ["tunedeck-xvfb.service"];
    requires = ["tunedeck-xvfb.service"];
    partOf = ["tunedeck-xvfb.service"];
    wantedBy = ["multi-user.target"];
    environment.DISPLAY = display;
    serviceConfig = {
      User = user;
      ExecStart = "${pkgs.openbox}/bin/openbox --sm-disable";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.services.spotify-headless = {
    description = "Spotify desktop client, headless and muted, for stat mirroring";
    after = ["network-online.target" "tunedeck-xvfb.service"];
    wants = ["network-online.target"];
    requires = ["tunedeck-xvfb.service"];
    partOf = ["tunedeck-xvfb.service"];
    wantedBy = ["multi-user.target"];
    environment.HOME = spotifyHome;
    serviceConfig = {
      User = user;
      ExecStart = inSession "spotify" "${pkgs.spotify}/bin/spotify --disable-gpu";
      Restart = "always";
      RestartSec = "20s";
      # Spotify ignores SIGTERM for a long time; without this every rebuild
      # stalls 90s waiting for it before SIGKILL.
      TimeoutStopSec = "15s";
    };
  };

  systemd.services.tunedeck-mirror = {
    description = "Mirror Navidrome playback onto Spotify";
    after = ["spotify-headless.service" "navidrome.service"];
    wants = ["spotify-headless.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = user;
      EnvironmentFile = config.sops.templates."tunedeck-env".path;
      ExecStart = inSession "mirror" "${tunedeck}/bin/tunedeck mirror";
      Restart = "always";
      RestartSec = "30s";
    };
  };

  # --- console -------------------------------------------------------------
  # Same trust model as home/system/remote-desktop: VNC itself is
  # unauthenticated and the tailnet IS the authentication. Note this is
  # strictly stronger than that module — anyone on the tailnet can drive
  # tunedeck-browser here, which is a browser running as ${user}. Set
  # var.tunedeck.console = false to turn it off once setup is done.
  systemd.services.tunedeck-vnc = lib.mkIf console {
    description = "x11vnc exposing ${display}";
    after = ["tunedeck-xvfb.service"];
    requires = ["tunedeck-xvfb.service"];
    partOf = ["tunedeck-xvfb.service"];
    wantedBy = ["multi-user.target"];
    environment.DISPLAY = display;
    serviceConfig = {
      User = user;
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display ${display} -localhost -rfbport ${toString vncPort} -forever -shared -nopw -noxdamage -quiet";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.services.tunedeck-novnc = lib.mkIf console {
    description = "noVNC web client fronting tunedeck-vnc";
    after = ["tunedeck-vnc.service"];
    requires = ["tunedeck-vnc.service"];
    partOf = ["tunedeck-vnc.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = user;
      ExecStart = "${pkgs.python3Packages.websockify}/bin/websockify --web=${pkgs.novnc}/share/webapps/novnc ${toString webPort} 127.0.0.1:${toString vncPort}";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
