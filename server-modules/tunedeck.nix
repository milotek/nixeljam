# tunedeck (base) — shared plumbing for spotify-mirror.nix and playlist-sync.nix.
#
# Imported by both of those, never on its own. Owns the package, the sops
# secrets, the single env file every tunedeck unit reads, and the state dir.
#
# SECRETS (sops hosts/minipc/secrets/system-secrets.yaml)
#   spotify-client-id      from https://developer.spotify.com/dashboard
#   spotify-client-secret  ditto
#   copyparty-password     already there; reused as the Navidrome password,
#                          same as slskd does
#
# The Spotify app's redirect URI must be exactly http://127.0.0.1:8974/callback.
#
# After a rebuild, authorise once:  sudo -u milotek tunedeck-auth
# Then any tunedeck subcommand:     sudo -u milotek tunedeck-auth status
{
  config,
  pkgs,
  ...
}: let
  tunedeck = import ../pkgs/tunedeck/package.nix {inherit pkgs;};
  user = config.var.username;
  music = config.services.navidrome.settings.MusicFolder;

  # Runs any tunedeck subcommand with the unit's environment, so an interactive
  # `tunedeck-auth status` sees exactly what the timer and the daemon see.
  # Defaults to `auth` because that is the one-off you actually need a shell for.
  tunedeckAuth = pkgs.writeShellScriptBin "tunedeck-auth" ''
    set -a
    . ${config.sops.templates."tunedeck-env".path}
    set +a
    exec ${tunedeck}/bin/tunedeck "''${@:-auth}"
  '';
in {
  environment.systemPackages = [tunedeck tunedeckAuth];

  sops.secrets.spotify-client-id = {
    owner = user;
    mode = "0400";
  };

  sops.secrets.spotify-client-secret = {
    owner = user;
    mode = "0400";
  };

  sops.templates."tunedeck-env" = {
    owner = user;
    mode = "0400";
    content = ''
      TUNEDECK_STATE=/var/lib/tunedeck
      SPOTIFY_CLIENT_ID=${config.sops.placeholder."spotify-client-id"}
      SPOTIFY_CLIENT_SECRET=${config.sops.placeholder."spotify-client-secret"}
      SPOTIFY_REDIRECT_URI=http://127.0.0.1:8974/callback
      NAVIDROME_URL=http://127.0.0.1:${toString config.services.navidrome.settings.Port}
      NAVIDROME_USER=${user}
      NAVIDROME_PASSWORD=${config.sops.placeholder."copyparty-password"}
      MUSIC_DIR=${music}
      PLAYLIST_DIR=${music}/Playlists
      DOWNLOAD_DIR=${music}/Songs/Tunedeck
      MIRROR_DEVICE=${config.var.hostname}
      MIRROR_DAILY_LIMIT_MINUTES=${toString config.var.tunedeck.mirrorDailyLimitMinutes}
      MAX_DOWNLOADS_PER_RUN=${toString config.var.tunedeck.maxDownloadsPerRun}
      AUTO_DOWNLOAD=${
        if config.var.tunedeck.autoDownload
        then "1"
        else "0"
      }
      SYNC_LIKED=${
        if config.var.tunedeck.syncLiked
        then "1"
        else "0"
      }
      SOUNDCLOUD_URLS=${builtins.concatStringsSep "," config.var.tunedeck.soundcloudUrls}
    '';
  };

  # Playlists and downloads land inside the Navidrome music folder so the
  # scanner picks both up with no extra configuration. copyparty serves the same
  # tree, so they show up in the file browser too.
  systemd.tmpfiles.rules = [
    "d /var/lib/tunedeck 0700 ${user} users - -"
    "d ${music}/Playlists 0775 ${user} users - -"
    "d ${music}/Songs/Tunedeck 0775 ${user} users - -"
  ];
}
