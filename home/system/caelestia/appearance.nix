{config, ...}: {
  programs.caelestia.settings = {
    appearance = {
      transparency = {
        base = 0.85;
        layers = 0.4;
      };
      font = {
        headline.family = config.stylix.fonts.sansSerif.name;
        title.family = config.stylix.fonts.sansSerif.name;
        body.family = config.stylix.fonts.sansSerif.name;
        label.family = config.stylix.fonts.sansSerif.name;
        mono.family = config.stylix.fonts.monospace.name;
      };
    };

    border.thickness = config.theme.gaps-in;

    dashboard.showOnHover = false;

    lock = {
      recolourLogo = true;
      enableFprint = false;
    };

    paths.wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";

    utilities = {
      enabled = true;
      maxToasts = 4;
      toasts = {
        audioInputChanged = false;
        audioOutputChanged = false;
        capsLockChanged = false;
        chargingChanged = true;
        configLoaded = false;
        dndChanged = true;
        gameModeChanged = true;
        numLockChanged = false;
        nowPlaying = false;
        kbLayoutChanged = false;
        vpnChanged = true;
      };
    };
  };
}
