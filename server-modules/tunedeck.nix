# tunedeck (base) — shared plumbing for spotify-mirror.nix and playlist-sync.nix.
#
# Imported by both of those, never on its own. Owns the package, the sops
# secrets, the single env file every tunedeck unit reads, and the state dir.
#
# SPOTIFY CREDENTIALS. Two ways, picked by var.tunedeck.ownSpotifyApp.
#
#   false (default) — ride spotdl's credentials. spotdl hardcodes a public
#     client id/secret and writes them to ~/.config/spotdl/config.json on first
#     run, which is why nothing here needed registering. Its app has
#     http://127.0.0.1:9900/ registered as a redirect URI, and Spotify does not
#     pre-register scopes per app, so our scopes work through it fine.
#     Cost: the rate limit is shared with every spotdl user on earth, and if
#     Spotify ever revokes that app everything here stops at once.
#
#   true — your own app from https://developer.spotify.com/dashboard, with
#     redirect URI exactly http://127.0.0.1:8974/callback, and these in
#     sops hosts/minipc/secrets/system-secrets.yaml:
#       spotify-client-id
#       spotify-client-secret
#     Worth doing if the shared app starts returning 429s.
#
# Either way copyparty-password is reused as the Navidrome password, same as
# slskd does. Switching between the two invalidates the cached token, so
# re-run tunedeck-auth afterwards.
#
# After a rebuild, authorise once:  sudo -u milotek tunedeck-auth
# Then any tunedeck subcommand:     sudo -u milotek tunedeck-auth status
{
  config,
  lib,
  pkgs,
  ...
}: let
  tunedeck = import ../pkgs/tunedeck/package.nix {inherit pkgs;};
  user = config.var.username;
  music = config.services.navidrome.settings.MusicFolder;
  ownApp = config.var.tunedeck.ownSpotifyApp;

  # spotdl's public credentials, verbatim from spotdl/utils/config.py. Not a
  # secret by any definition — they ship in the package and land in every
  # user's ~/.config/spotdl/config.json.
  spotdlCreds = {
    id = "5f573c9620494bae87890c0f08a60293";
    secret = "212476d9b0f3472eaa762d90b19b0ba8";
    redirect = "http://127.0.0.1:9900/"; # the only URI that app has registered
  };

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

  # optionalAttrs, not mkIf: mkIf inside an attrsOf option still creates the
  # key, and sops-nix would then fail activation demanding a secret that the
  # yaml does not have.
  sops.secrets = lib.optionalAttrs ownApp {
    spotify-client-id = {
      owner = user;
      mode = "0400";
    };
    spotify-client-secret = {
      owner = user;
      mode = "0400";
    };
  };

  sops.templates."tunedeck-env" = {
    owner = user;
    mode = "0400";
    content = ''
      TUNEDECK_STATE=/var/lib/tunedeck
      SPOTIFY_CLIENT_ID=${
        if ownApp
        then config.sops.placeholder."spotify-client-id"
        else spotdlCreds.id
      }
      SPOTIFY_CLIENT_SECRET=${
        if ownApp
        then config.sops.placeholder."spotify-client-secret"
        else spotdlCreds.secret
      }
      SPOTIFY_REDIRECT_URI=${
        if ownApp
        then "http://127.0.0.1:8974/callback"
        else spotdlCreds.redirect
      }
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
