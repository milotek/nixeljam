{
  networking.hostName = "pc";

  nixeljam = {
    username = "milotek";
    git = {
      name = "Milo Tekchandani";
      email = "milo@milotek.dev";
    };
    extraLocale = "en_US.UTF-8";
  };

  services.xserver.xkb.layout = "gb";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
}
