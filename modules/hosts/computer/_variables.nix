{
  networking.hostName = "computer"; # CHANGEME

  nixeljam = {
    username = "user"; # CHANGEME
    git = {
      name = "Your Name"; # CHANGEME
      email = "you@example.com"; # CHANGEME
    };
    extraLocale = "en_US.UTF-8"; # CHANGEME
  };

  services.xserver.xkb.layout = "us"; # CHANGEME

  time.timeZone = "America/New_York"; # CHANGEME
  i18n.defaultLocale = "en_US.UTF-8";
}
