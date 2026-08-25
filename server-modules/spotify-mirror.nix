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
# SETUP, after `nixos-rebuild switch` with the secrets from tunedeck.nix in place
#
#   1. tunedeck-login                     log the headless profile in, once,
#                                         from a graphical session
#   2. sudo -u milotek tunedeck-auth      authorise the API side, once
#   3. systemctl restart spotify-headless tunedeck-mirror
#
# Watch it: sudo -u milotek tunedeck-auth status, journalctl -fu tunedeck-mirror
{
  config,
  pkgs,
  ...
}: let
  tunedeck = import ../pkgs/tunedeck/package.nix {inherit pkgs;};
  user = config.var.username;

  # Its own HOME, so the headless client keeps a separate profile instead of
  # fighting the desktop Spotify over ~/.config/spotify.
  spotifyHome = "/var/lib/tunedeck/spotify-home";

  # MPRIS lives on the session bus, so these units have to join the user's
  # session rather than run in isolation. %U expands to the UID behind User=,
  # which beats hardcoding 1000.
  sessionEnv = {
    XDG_RUNTIME_DIR = "/run/user/%U";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/%U/bus";
    PULSE_SERVER = "unix:/run/user/%U/pulse/native";
    PULSE_SINK = "tunedeck-null";
    DISPLAY = ":97";
  };

  tunedeckLogin = pkgs.writeShellScriptBin "tunedeck-login" ''
    # Runs the headless profile's Spotify on your real display, once, so you can
    # type the password. Close the window when the library has loaded.
    echo "logging in the headless profile (HOME=${spotifyHome})"
    mkdir -p ${spotifyHome}
    HOME=${spotifyHome} exec ${pkgs.spotify}/bin/spotify "$@"
  '';
in {
  imports = [./tunedeck.nix];

  environment.systemPackages = [tunedeckLogin pkgs.playerctl];

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

  systemd.tmpfiles.rules = ["d ${spotifyHome} 0700 ${user} users - -"];

  # Both units live in the user's session, so they have to wait for it. The
  # ordering dep is belt-and-braces — Restart=always is what actually covers the
  # boot race, since a session bus that is not up yet just means one retry.
  systemd.services.spotify-headless = {
    description = "Spotify desktop client, headless and muted, for stat mirroring";
    after = ["network-online.target" "user@%U.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    environment = sessionEnv // {HOME = spotifyHome;};
    serviceConfig = {
      User = user;
      # xvfb-run supplies the X server the client insists on; nothing is ever
      # rendered to a screen.
      ExecStart = "${pkgs.xvfb-run}/bin/xvfb-run -n 97 -s '-screen 0 1280x800x24' ${pkgs.spotify}/bin/spotify --disable-gpu";
      Restart = "always";
      RestartSec = "20s";
    };
  };

  systemd.services.tunedeck-mirror = {
    description = "Mirror Navidrome playback onto Spotify";
    after = ["spotify-headless.service" "navidrome.service" "user@%U.service"];
    wants = ["spotify-headless.service"];
    wantedBy = ["multi-user.target"];
    environment = sessionEnv;
    serviceConfig = {
      User = user;
      EnvironmentFile = config.sops.templates."tunedeck-env".path;
      ExecStart = "${tunedeck}/bin/tunedeck mirror";
      Restart = "always";
      RestartSec = "30s";
    };
  };
}
