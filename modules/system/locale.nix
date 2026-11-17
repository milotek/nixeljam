# Time zone, language and keyboard layout (hosts can override any of these)
{
  flake.modules.nixos.locale = {
    config,
    lib,
    ...
  }: let
    extraLocale = "en_US.UTF-8"; # CHANGEME
  in {
    time.timeZone = lib.mkDefault "America/New_York"; # CHANGEME

    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      extraLocaleSettings = lib.mapAttrs (_: lib.mkDefault) {
        LC_ADDRESS = extraLocale;
        LC_IDENTIFICATION = extraLocale;
        LC_MEASUREMENT = extraLocale;
        LC_MONETARY = extraLocale;
        LC_NAME = extraLocale;
        LC_NUMERIC = extraLocale;
        LC_PAPER = extraLocale;
        LC_TELEPHONE = extraLocale;
        LC_TIME = extraLocale;
      };
    };

    services.xserver.xkb.layout = lib.mkDefault "us"; # CHANGEME
    console.keyMap = lib.mkDefault config.services.xserver.xkb.layout;
  };
}
