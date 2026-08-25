{
  config,
  lib,
  ...
}: {
  imports = [
    ../../themes/pixeljam.nix
  ];

  config.var = {
    hostname = "minipc";
    username = "milotek";
    configDirectory = "/home/" + config.var.username + "/.config/nixos";

    keyboardLayout = "gb";

    timeZone = "Europe/London";
    defaultLocale = "en_GB.UTF-8";
    extraLocale = "en_US.UTF-8";

    git = {
      username = "Milo Tekchandani";
      email = "milo@milotek.dev";
    };

    # Numeric Telegram ID from @userinfobot. Until this is set, openclaw runs
    # with no chat channel attached.
    openclawTelegramUserId = null;

    # tunedeck — Spotify/SoundCloud <-> Navidrome bridge.
    # See server-modules/tunedeck.nix, spotify-mirror.nix, playlist-sync.nix.
    tunedeck = {
      # Public SoundCloud playlist/likes URLs to pull down on every sync run.
      soundcloudUrls = [];

      # Fetch tracks a Spotify playlist references but the library lacks.
      autoDownload = true;
      maxDownloadsPerRun = 25;
      syncLiked = true;

      # Ceiling on mirrored playback, to protect the free tier's daily
      # on-demand allowance for actual listening. Minutes per day.
      mirrorDailyLimitMinutes = 240;

      # Browser-accessible view of the mirror's headless display, over the
      # tailnet. Needed to log Spotify in on a box with no desktop session;
      # worth turning off once setup is done, since it also exposes
      # tunedeck-browser to anything on the tailnet.
      console = true;

      # false rides spotdl's public client id/secret, so nothing needs
      # registering. Flip to true (and add spotify-client-id /
      # spotify-client-secret to sops) if the shared app starts rate-limiting.
      ownSpotifyApp = false;

      # Flip on once lastfm-api-key and lastfm-secret are in sops. Until then
      # Navidrome scrobbles to ListenBrainz only.
      lastfm = false;
    };

    autoUpgrade = false;
    autoGarbageCollector = true;

    domain = "tek.rip";
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
