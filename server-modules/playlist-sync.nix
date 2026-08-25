# playlist-sync — two-way playlist sync between Spotify and Navidrome, plus a
# SoundCloud pull, plus fetching whatever the library is missing.
#
# Unlike the mirror this part needs nothing from Spotify that a free account
# cannot do: reading your playlists and liked songs, and creating/updating
# playlists you own, are all free-tier operations.
#
# WHAT A RUN DOES
#
#   SoundCloud -> disk   scdl pulls the URLs in var.tunedeck.soundcloudUrls.
#                        SoundCloud closed its public API to new apps years ago,
#                        so scraping public URLs is the only route left.
#   Spotify -> Navidrome every playlist (and Liked Songs) is matched against the
#                        local library and written as an .m3u under
#                        <music>/Playlists, which is how Navidrome imports
#                        playlists. Unmatched tracks go to the wanted list.
#   Navidrome -> Spotify every local playlist is matched up to Spotify tracks and
#                        pushed to a playlist you own.
#   wanted -> disk       spotdl fetches the missing tracks (rate-limited per run)
#                        into <music>/Songs/Tunedeck, so the next run matches
#                        them locally instead.
#
# LOOP PREVENTION: pulled playlists are named "[sp] Foo" locally, pushed ones
# "[nd] Bar" on Spotify. Each direction skips the other's prefix, so a playlist
# never chases its own tail. Do not rename them by hand.
#
# Timer runs every 30 minutes. Force one with:
#   systemctl start tunedeck-sync
#   sudo -u milotek tunedeck-auth sync --only pull    # or push / soundcloud
{
  config,
  pkgs,
  ...
}: let
  tunedeck = import ../pkgs/tunedeck/package.nix {inherit pkgs;};
  user = config.var.username;
in {
  imports = [./tunedeck.nix];

  systemd.services.tunedeck-sync = {
    description = "Sync playlists between Spotify, SoundCloud and Navidrome";
    after = ["network-online.target" "navidrome.service"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      User = user;
      EnvironmentFile = config.sops.templates."tunedeck-env".path;
      ExecStart = "${tunedeck}/bin/tunedeck sync";
      # spotdl fetching a backlog can run long; do not let systemd kill it
      # mid-download and leave partial files in the library.
      TimeoutStartSec = "2h";
    };
  };

  systemd.timers.tunedeck-sync = {
    description = "Periodic playlist sync";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "30m";
      RandomizedDelaySec = "5m";
      Persistent = true;
    };
  };
}
