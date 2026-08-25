# Navidrome — Subsonic-compatible server over the copyparty music tree.
# Reachable on 4533 over the tailnet; the VPS's caddy fronts it at
# https://music.<domain>.
#
# SCROBBLING. Navidrome scrobbles natively, and this is the part that actually
# solves "I want my stats in one place": every play here lands in Last.fm and/or
# ListenBrainz, and Last.fm can pull your Spotify plays in on its own (Settings
# -> Applications -> connect Spotify, no software needed). That gives one
# unified history across both players, which is the thing stats.fm cannot do —
# it only ever sees Spotify.
#
#   ListenBrainz: enabled by default. Each user pastes their token in the
#                 Navidrome UI (Personal -> Settings -> ListenBrainz).
#   Last.fm:      needs your own API key, since Navidrome ships none. Get one at
#                 https://www.last.fm/api/account/create, put it in sops as
#                 lastfm-api-key / lastfm-secret, then set
#                 var.tunedeck.lastfm = true in hosts/minipc/variables.nix.
#                 Connect the account afterwards in the Navidrome UI.
#
# AutoImportPlaylists picks up the .m3u files playlist-sync.nix writes into
# <MusicFolder>/Playlists. PlaylistsPath is left at its default (empty = every
# folder in the library) so hand-made playlists elsewhere keep working too.
{
  config,
  lib,
  ...
}: let
  lastfm = config.var.tunedeck.lastfm;
in {
  services.navidrome = {
    enable = true;
    environmentFile = lib.mkIf lastfm config.sops.templates."navidrome-env".path;
    settings =
      {
        MusicFolder = "/var/lib/copyparty/Music";
        Address = "0.0.0.0";
        Port = 4533;

        AutoImportPlaylists = true;
        ListenBrainz.Enabled = true;
      }
      // lib.optionalAttrs lastfm {
        LastFM.Enabled = true;
      };
  };

  # Navidrome's NixOS module renders settings into a world-readable JSON file, so
  # the Last.fm key goes in through the environment instead.
  # lib.optionalAttrs, not lib.mkIf: mkIf inside an attrsOf option still creates
  # the key, which would make sops-nix demand a secret that does not exist.
  sops.secrets = lib.optionalAttrs lastfm {
    lastfm-api-key.owner = "navidrome";
    lastfm-secret.owner = "navidrome";
  };

  sops.templates = lib.optionalAttrs lastfm {
    "navidrome-env" = {
      owner = "navidrome";
      mode = "0400";
      content = ''
        ND_LASTFM_APIKEY=${config.sops.placeholder."lastfm-api-key"}
        ND_LASTFM_SECRET=${config.sops.placeholder."lastfm-secret"}
      '';
    };
  };
}
