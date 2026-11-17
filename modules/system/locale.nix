{
  flake.modules.nixos.locale = {
    config,
    lib,
    ...
  }: let
    extraLocale = config.nixeljam.extraLocale;
  in {
    options.nixeljam.extraLocale = lib.mkOption {
      type = lib.types.str;
      default = config.i18n.defaultLocale;
      description = "Locale for formats (dates, numbers, units, currency...)";
    };

    config = {
      i18n.extraLocaleSettings = {
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

      console.keyMap = lib.mkDefault config.services.xserver.xkb.layout;
    };
  };
}
