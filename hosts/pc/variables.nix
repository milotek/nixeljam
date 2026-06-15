{
  config,
  lib,
  ...
}: {
  imports = [
    # Choose your theme here:
    ../../themes/pixeljam.nix
  ];

  config.var = {
    hostname = "milotek-pc-linux";
    username = "milotek";
    configDirectory = "/home/" + config.var.username + "/.config/nixos"; # The path of the nixos configuration directory

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

  # DON'T TOUCH THIS
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
