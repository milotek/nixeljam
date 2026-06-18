{
  config,
  lib,
  ...
}: {
  imports = [
    ../../themes/pixeljam.nix
  ];

  config.var = {
    hostname = "milotek-minipc";
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

    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
